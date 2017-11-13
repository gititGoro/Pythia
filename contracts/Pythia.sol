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
    mapping (address => mapping (address => uint8)) winningTower;
    mapping (string => PassiveKreshmoi[]) predictions;
    mapping (address => mapping (string => Prophecy[])) prophecies;
    mapping(address => mapping (string => uint)) averageFrequencyPerFeed;
    mapping (address => mapping(string => uint)) lastBlockOffered;

    function rewardPythia(string datafeed, uint8 requiredSampleSize,uint minimumFrequency, int128 maxValueRange,uint8 decimalPlaces, uint8 minimumwinningTower, address originalSender) payable {
        int128[] memory registers = new int128[](4); //0 = lower range, 1 = upper range, 2 = average,3 = reward
        originalSender = originalSender == address(0) ? msg.sender:originalSender;
        registers[3] = int128(msg.value / requiredSampleSize);
        if (registers[3] <= 0) {
            ScanPredictionsFailed(originalSender, "ether reward too small");
            refundsForFailedBounties[originalSender] += msg.value;
            return;
        }

        RewardPerOrace(registers[3]);

        uint predictionCount = predictions[datafeed].length;

        if (predictionCount >= requiredSampleSize && predictionCount>0) {
            registers[0] = predictions[datafeed][predictionCount-1].prediction;
            registers[1] = predictions[datafeed][predictionCount-1].prediction;    
        } else {
            ScanPredictionsFailed(originalSender, "too few predictions");
            refundsForFailedBounties[originalSender] += msg.value;
            return;
        }

        address[] memory winners = new address[](requiredSampleSize);

        for (uint i = predictionCount-1;i >= 0 && requiredSampleSize>0 ;i--) {
            if (winningTower[msg.sender][predictions[datafeed][i].oracle]<minimumwinningTower)
                continue;

            if (averageFrequencyPerFeed[msg.sender][datafeed] == 0 || averageFrequencyPerFeed[msg.sender][datafeed] > minimumFrequency)
                continue;

            if (predictions[datafeed][i].decimalPlaces != decimalPlaces)
                continue;

            if (predictions[datafeed][i].prediction<registers[0]) {
                if (registers[1] - predictions[datafeed][i].prediction>maxValueRange) {
                    PredictionNotInAcceptableRange(predictions[datafeed][i].oracle, originalSender);
                    if (winningTower[msg.sender][predictions[datafeed][i].oracle]>0)
                         winningTower[msg.sender][predictions[datafeed][i].oracle]--;
                    continue;
                }
                registers[0] = predictions[datafeed][i].prediction;
            } else if (predictions[datafeed][i].prediction>registers[1]) {
                if (predictions[datafeed][i].prediction - registers[0]>maxValueRange ) {
                    PredictionNotInAcceptableRange(predictions[datafeed][i].oracle,originalSender);
                    if (winningTower[msg.sender][predictions[datafeed][i].oracle]>0)
                        winningTower[msg.sender][predictions[datafeed][i].oracle] = 0;
                    continue;
                }
                registers[1] = predictions[datafeed][i].prediction;
            }
            registers[2] += predictions[datafeed][i].prediction;
            requiredSampleSize--;
            winners[requiredSampleSize] = predictions[datafeed][i].oracle;
        }

        if (requiredSampleSize>0) {
            ScanPredictionsFailed(originalSender, "required sample size not met");
            refundsForFailedBounties[originalSender] += msg.value;
            return;
        }

        for (i = 0;i<winners.length;i++) {
            if (winners[i]!=address(0)) {
            winningTower[msg.sender][winners[i]]++;
            rewardForSuccessfulProphecies[winners[i]] += uint(registers[3]);
            }
        }

        Prophecy memory success = Prophecy({
            sumOfPredictions: registers[2],
            decimalPlaces:decimalPlaces,
            sampleSize:uint8(winners.length),
            blockNumber:block.number
        });
        prophecies[msg.sender][datafeed].push(success);
    }

    function scanProphecies(string datafeed,uint16 maxBlockRange, uint8 decimalPlaces) returns (int128 sumOfPredictions, uint8 sampleSize, bool success) {
     sumOfPredictions = 0; success = false;
        for (uint i = prophecies[msg.sender][datafeed].length;i > 0; i--) {
            if (prophecies[msg.sender][datafeed][i].blockNumber<block.number-maxBlockRange)
                return;
            if (prophecies[msg.sender][datafeed][i].decimalPlaces != decimalPlaces)
                continue;
            success = true;
            sumOfPredictions = prophecies[msg.sender][datafeed][i].sumOfPredictions;
            sampleSize = prophecies[msg.sender][datafeed][i].sampleSize;
            return;
        }
    }

    function passiveOfferKreshmoi (string datafeed, int64 prediction, uint8 decimalPlaces) {
        predictions[datafeed].push(PassiveKreshmoi({
            oracle:msg.sender,
            prediction:prediction,
            decimalPlaces:decimalPlaces,
            blockNumber:block.number
        }));
        calculateKreshmoiFrequency(datafeed, msg.sender);
    }

    function calculateKreshmoiFrequency (string datafeed, address oracle) internal {
      if (averageFrequencyPerFeed[oracle][datafeed]==0) {
          if (lastBlockOffered[oracle][datafeed] > 0)
            averageFrequencyPerFeed[oracle][datafeed] = block.number - lastBlockOffered[oracle][datafeed];
      } else {
         averageFrequencyPerFeed[oracle][datafeed] = (block.number - lastBlockOffered[oracle][datafeed] + averageFrequencyPerFeed[oracle][datafeed])/2;
      }

      lastBlockOffered[oracle][datafeed] = block.number;
        /*1
            mapping(address => mapping (string => uint32)) averageFrequencyPerFeed;
    mapping (address => mapping(string => uint)) lastBlockOffered;
        if(frequency>0)
(current block – last block + frequency)/2
else 
current block – last block
 */
    }
    
    //passive functions END
  

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

    event RewardPerOrace(int128 number);
}