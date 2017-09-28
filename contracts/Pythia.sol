pragma solidity ^0.4.11;
//TODO: read security stuff
//TODO: when placing a bid, do an inplace sort so that the final request doesn't run out of gas
//SECURITY: Always change all variables and only as the very last act, transfer ether.
//SECURITY: perform all bookkeeping on the same scope level in case malicious actor gets stack to 1024 and then you try to do something with function call and 
//it isn't atomic
//SECURITY: use invariants to trigger safe mode if any of the invariants become inconsistent.
//TODO: add modifier to allow owner to disable the entire contract in case I want to launch a newer version.
//TODO: make a withdrawal function
//TODO: Implement GetBounty with datafeed and decimla places
//TODO: check how many pythia we can tolerate before gas becomes a problem
/*Domain language: Post bounty, OfferKreshmoi, Reward bounty, 
Collect bounty reward, Successful kreshmoi
*/
//TODO: implement a GetBountyReward to check the reward offered on each bounty. 

import "./StringUtils.sol";
import "./PythiaBase.sol";

contract Pythia is PythiaBase {

    mapping (address => uint) rewardForSuccessfulProphecies; //stores the ether value of each successful kreshmoi. And yes, you can forget about reentrancy attacks.
    mapping (string => Kreshmoi[]) successfulKreshmoi; //key is USDETH or CPIXZA for instance
    mapping (string => Bounty[]) openBounties; 
    mapping (address => uint) refundsForFailedBounties;
    mapping (address => uint) donations;
    mapping (string => string) datafeedDescriptions;
    mapping (string => uint) datafeedChangeCost;
    string[] datafeedNames;
    mapping (address => PostBountyDetails ) validationTickets;
    function Pythia() {
        
    }

    function() payable {
        donations[msg.sender] = msg.value;
    }

    //passive functions START
    mapping (address => mapping (address => uint8)) winningStreak;
    mapping (string => PassiveKreshmoi[]) predictions;
    mapping (address => mapping (string => Prophecy[])) prophecies;

    function rewardPythia(string datafeed, uint8 requiredSampleSize,uint16 maxBlockRange,int128 maxValueRange,uint8 decimalPlaces, uint8 minimumWinningStreak) payable {
        int128[] memory registers = new int128[](4); //0 = lower range, 1 = upper range, 2 = average,3 = reward
        registers[3] = int128(msg.value / requiredSampleSize);
        if (registers[3]<=0) {
            ScanPredictionsFailed(msg.sender, "ether reward too small");
            refundsForFailedBounties[msg.sender] += msg.value;
            return;
        }

        uint predictionCount = predictions[datafeed].length;

        if (predictionCount >= requiredSampleSize && predictionCount>0) {
            registers[0] = predictions[datafeed][predictionCount-1].prediction;
            registers[1] = predictions[datafeed][predictionCount-1].prediction;    
        }else {
            ScanPredictionsFailed(msg.sender, "too few predictions");
            refundsForFailedBounties[msg.sender] += msg.value;
            return;
        }

        address[] memory winners = new address[](requiredSampleSize);

        for (uint i = predictionCount-1;i >= 0 && requiredSampleSize>0 ;i--) {
            if (winningStreak[msg.sender][predictions[datafeed][i].oracle]<minimumWinningStreak)
                continue;
            
            if (predictions[datafeed][i].blockNumber < block.number - maxBlockRange)
                continue;

            if (predictions[datafeed][i].decimalPlaces != decimalPlaces)
                continue;

            if (predictions[datafeed][i].prediction<registers[0]) {
                if (registers[1] - predictions[datafeed][i].prediction>maxValueRange) {
                    PredictionNotInAcceptableRange(predictions[datafeed][i].oracle, msg.sender);
                    continue;
                }
                registers[0] = predictions[datafeed][i].prediction;
            }else if (predictions[datafeed][i].prediction>registers[1]) {
                if (predictions[datafeed][i].prediction>maxValueRange - registers[0]) {
                    PredictionNotInAcceptableRange(predictions[datafeed][i].oracle, msg.sender);
                    continue;
                }
                registers[1] = predictions[datafeed][i].prediction;
            }
            registers[2] += predictions[datafeed][i].prediction;
            requiredSampleSize--;
            winners[requiredSampleSize] = predictions[datafeed][i].oracle;
        }

        if (requiredSampleSize>0) {
            ScanPredictionsFailed(msg.sender, "required sample size not met");
            refundsForFailedBounties[msg.sender] += msg.value;
            return;
        }

        for (i = 0;i<winners.length;i++) {
            winningStreak[msg.sender][winners[i]]++;
            rewardForSuccessfulProphecies[winners[i]] += uint(registers[3]);
        }
        Prophecy memory success = Prophecy({
            sumOfPredictions: registers[2],
            decimalPlaces:decimalPlaces,
            sampleSize:uint8(winners.length)
        });
        prophecies[msg.sender][datafeed].push(success);
    }

    
    //TODO: implement PassiveOfferKreshmoi
    //TODO: implement scanProphecies
    //passive functions END
    function setDescription(string datafeed, string description) payable {
        uint index = 0;
        for (uint i = 0; i < datafeedNames.length; i++) {
            if (StringUtils.equal(datafeedNames[i], datafeed)) {
                index = i;
                break;
            }
        }

        if (index==0) {
            if (msg.value>=1)
                datafeedNames.push(datafeed);
            datafeedChangeCost[datafeed] = 1;
            datafeedDescriptions[datafeed] = description;
        } else if (msg.value>=datafeedChangeCost[datafeed]*2) {
                datafeedNames[index] = description;
                datafeedChangeCost[datafeed] *= 2;
                datafeedDescriptions[datafeed] = description;
        }
    }

    function getDatafeedNameChangeCost(string datafeed) returns (uint) {
        if (datafeedChangeCost[datafeed]==0) {
            return 1;
        }
        return datafeedChangeCost[datafeed]*2;
    }

    function getDescriptionByName(string datafeed) returns (string) {
        return datafeedDescriptions[datafeed];
    }

    function getDescriptionByIndex(uint index) returns (string) {
        if (index<0 || index > datafeedNames.length) {
         Debugging("Index out of bounds");
         return "ERROR: INDEX OUT OF BOUNDS";
        }
        return datafeedNames[index];
    }

    function generatePostBountyValidationTicket(string datafeed,uint8 requiredSampleSize,uint16 maxBlockRange,uint maxValueRange,uint8 decimalPlaces) payable {
        bool validationSuccess = true;
         if (msg.value/requiredSampleSize<1) {
            BountyValidationCheckFailed(datafeed,msg.sender,"ether reward too small");
            validationSuccess = false;
        }

        if (requiredSampleSize<2) {
             BountyValidationCheckFailed(datafeed,msg.sender,"At least 2 predictions for an oracle to be considered a pythia");
             validationSuccess = false;
        }

        if (validateDataFeedFails(datafeed,msg.sender)) {
            validationSuccess = false;
        }

         if (openBounties[datafeed].length>10) {
            BountListFull(datafeed);
            validationSuccess = false;
        }

        if (validationSuccess) {
            validationTickets[msg.sender] = PostBountyDetails({datafeed:datafeed,
            value:msg.value,
            sampleSize:requiredSampleSize,
            maxBlockRange:maxBlockRange,
            maxValueRange:maxValueRange,
            decimalPlaces:decimalPlaces,
            fresh:true});
        }

        refundsForFailedBounties[msg.sender] += msg.value;
        ValidationTicketGenerated(msg.sender);
    }

    function pushOldBountiesOffCliff(string datafeed) {

         if (openBounties[datafeed].length>0) {
            address refundAddress = openBounties[datafeed][0].poster;
            uint refund = openBounties[datafeed][0].szaboRewardPerOracle*openBounties[datafeed][0].requiredSampleSize;
            refundsForFailedBounties[refundAddress] += refund*9/10; //spam prevention penalty

            for (uint i = 0;i<openBounties[datafeed].length-1;i++) {
                openBounties[datafeed][i] = openBounties[datafeed][i+1];
            }
            delete openBounties[datafeed][openBounties[datafeed].length-1];
            openBounties[datafeed].length--;
        }
    }

    function postBounty() payable {
        PostBountyDetails memory validationObject;
        if (validationTickets[msg.sender].fresh) {
                validationObject = validationTickets[msg.sender];
                validationTickets[msg.sender].fresh= false;
        } else if (msg.value!=validationTickets[msg.sender].value) {
            InvalidBountyValidationTicket(msg.sender,validationTickets[msg.sender].datafeed);
            refundsForFailedBounties[msg.sender] += msg.value;
            return;
        }

        Bounty memory bounty = Bounty({
            maxBlockRange:validationObject.maxBlockRange,
            maxValueRange:validationObject.maxValueRange,
            szaboRewardPerOracle:(msg.value/validationObject.sampleSize)/1 szabo,
            requiredSampleSize:validationObject.sampleSize,
            decimalPlaces:validationObject.decimalPlaces,
            predictions: new int64[](validationObject.sampleSize),
            oracles: new address[](validationObject.sampleSize),
            earliestBlock:0,
            poster: msg.sender
        });

        openBounties[validationObject.datafeed].push(bounty);

        BountyPosted (msg.sender,validationObject.datafeed,bounty.szaboRewardPerOracle); 
    }
    
    function getOracleReward() returns (uint) { 
        return rewardForSuccessfulProphecies[msg.sender]*1 szabo;
    }

    function collectOracleReward() { 
        uint reward = getOracleReward();
        rewardForSuccessfulProphecies[msg.sender] = 0;
        msg.sender.transfer(reward);
    }

    function claimRefundsDue() {
        uint refund = refundsForFailedBounties[msg.sender];
        refundsForFailedBounties[msg.sender] = 0;
        RefundProcessed(msg.sender);
        msg.sender.transfer(refund);
        
    }

    function getBounties(string datafeed) returns (uint8[] sampleSize,uint8[] decimalPlaces,uint[] rewardPerOracle) {
        for (uint i = 0; i<openBounties[datafeed].length;i++) {
            sampleSize[i] = openBounties[datafeed][i].requiredSampleSize;
            decimalPlaces[i] = openBounties[datafeed][i].decimalPlaces;
            rewardPerOracle[i] = openBounties[datafeed][i].szaboRewardPerOracle;
        }
    }

    function offerKreshmoi(string datafeed, uint8 index, int64 predictionValue) {//TODO: limiting factor on number of open bounties to participate in
        Bounty memory bounty = openBounties[datafeed][index];

            if (bounty.earliestBlock==0 || block.number - uint(bounty.earliestBlock)>uint(bounty.maxBlockRange)) {
               clearBounty(datafeed,index,"Max block registers exceeded. All previous bounty hunters have been erased. Bounty reset at current block.");
            }

            int128[] memory registers = new int128[](4);//0 = smallest,1 = largest,2 = average value,3 = order of magnitude
            if (bounty.predictions.length>0) {
                registers[0] = bounty.predictions[0];
                registers[1] = bounty.predictions[0];
            } else {
                registers[0] = 0;
                registers[1] = 0;    
            }
      
            for (uint j = 1;j<bounty.predictions.length;j++) {
                registers[2] += bounty.predictions[j];
                if (registers[1] < bounty.predictions[j])
                    registers[1] = bounty.predictions[j];
                if (registers[0] > bounty.predictions[j])
                       registers[0] = bounty.predictions[j];
            }
       
            if (predictionValue > registers[1])
                registers[1] = predictionValue;
         
            if (uint(registers[1]-registers[0])>bounty.maxValueRange) {
                clearBounty(datafeed,index,"The kreshmoi offered exceeded the maximum allowable registers for this bounty. All previous bounty hunters have been erased. Bounty reset at current block.");
            }

            for (j = 0;j < openBounties[datafeed][index].oracles.length;j++) {
                if (openBounties[datafeed][index].oracles[j]==msg.sender) {
                     KreshmoiOfferFailed (msg.sender, datafeed, "oracle cannot post 2 predictions for same bounty");
                     return;
                }
            }

            openBounties[datafeed][index].predictions.push(predictionValue);
            openBounties[datafeed][index].oracles.push(msg.sender);
            
            if (openBounties[datafeed][index].predictions.length == bounty.requiredSampleSize) {
                registers[2] += predictionValue;
                registers[3] = 1;
                for (j = 0;j < openBounties[datafeed][index].decimalPlaces;j++) {
                     registers[3]*=10;
                }
                registers[2] *=  registers[3];
                registers[2] /= openBounties[datafeed][index].requiredSampleSize;
                successfulKreshmoi[datafeed].push(Kreshmoi({
                    blockRange: uint16(block.number - openBounties[datafeed][index].earliestBlock),
                    decimalPlaces:openBounties[datafeed][index].decimalPlaces,
                    value: int64(registers[2]),
                    sampleSize:openBounties[datafeed][index].requiredSampleSize,
                    valueRange:uint(registers[1]-registers[0]),
                    bountyPoster:openBounties[datafeed][index].poster
                }));
                
                 address[] memory oracles = bounty.oracles;
                 uint reward = bounty.szaboRewardPerOracle;
                 for (j = 0;j<oracles.length;j++) {
                     rewardForSuccessfulProphecies[oracles[j]] += reward;
                 }

                delete openBounties[datafeed][index];
                for (j = index;j<openBounties[datafeed].length-1;j++) {
                    openBounties[datafeed][j] = openBounties[datafeed][j+1];
                }
                KreshmoiOffered(msg.sender,datafeed);
                ProphecyDelivered(datafeed);
                return;
            }
            KreshmoiOffered(msg.sender,datafeed);
    }

    function getKreshmoi(string datafeed) returns (int64[],uint8[]) {
        int64[] memory values = new int64[](successfulKreshmoi[datafeed].length);
        uint8[] memory decimalPlaces = new uint8[](successfulKreshmoi[datafeed].length);

        for (uint i =0;i<successfulKreshmoi[datafeed].length;i++) {
            values[i] = successfulKreshmoi[datafeed][i].value;
            decimalPlaces[i] = successfulKreshmoi[datafeed][i].decimalPlaces;
        }
        return (values, decimalPlaces);
    }

    function clearBounty(string datafeed, uint index, string reason) internal {
                openBounties[datafeed][index].earliestBlock = block.number;
                delete openBounties[datafeed][index].predictions;
                delete openBounties[datafeed][index].oracles;
                BountyCleared(datafeed,index,reason);
    }

    function validateDataFeedFails(string datafeed, address sender) internal returns(bool) {
       bytes memory chararray = bytes(datafeed);
        if (chararray.length>10) {
            BountyValidationCheckFailed(datafeed,  sender, "datafeed name must contain at most 10 characters");
            return true;
        }

        if (chararray.length<3) {
            BountyValidationCheckFailed(datafeed,  sender, "datafeed name must contain at least 3 characters");
            return true;
        }

        string memory validString = "ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789";
        bytes memory validCharacterSet = bytes(validString);
        Debugging(datafeed);
        for (uint i = 0;i<chararray.length;i++) {
            bool existsInValidSet = false;
            for (uint j =0;j<36;j++) {
                if (chararray[i]==validCharacterSet[j])
                    existsInValidSet= true;
            }
            if (!existsInValidSet) {
                BountyValidationCheckFailed(datafeed, sender,"Characters must be uppercase alphanumeric.");
                return true;
            }
        }
        return false;
    }

    event Debugging(string message);
    event DebuggingUINT(string message,uint additional);
    event BountyValidationCheckFailed(string datafeed, address from, string reason);
    event InvalidBountyValidationTicket(address sender, string datafeed);
    event BountListFull(string datafeed);
    event BountyCleared(string datafeed, uint index, string reason);
    event BountyPosted (address from, string datafeed, uint rewardPerOracle);
    event KreshmoiOffered (address from, string datafeed);
    event KreshmoiOfferFailed (address from, string datafeed, string reason);
    event ProphecyDelivered (string datafeed);
    event RefundProcessed(address collector);
    event ValidationTicketGenerated(address bountyPost);

    //passive
    event PredictionNotInAcceptableRange (address oracle, address inquirer);
    event ScanPredictionsFailed (address inquirer, string reason);
}