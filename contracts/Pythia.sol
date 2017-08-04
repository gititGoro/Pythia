pragma solidity ^0.4.11;
//TODO: read security stuff
//TODO: when placing a bid, do an inplace sort so that the final request doesn't run out of gas
//SECURITY: Always change all variables and only as the very last act, transfer ether.
//SECURITY: perform all bookkeeping on the same scope level in case malicious actor gets stack to 1024 and then you try to do something with function call and 
//it isn't atomic
//SECURITY: use invariants to trigger safe mode if any of the invariants become inconsistent.
//TODO: add modifier to allow owner to disable the entire contract in case I want to launch a newer version.
//TODO: make a withdrawal function
/*Domain language: Post bounty, OfferKreshmoi, Reward bounty, 
Collect bounty reward, Successful kreshmoi
*/
import "./StringUtils.sol";
import "./PythiaBase.sol";

contract Pythia is PythiaBase{

    mapping (address => uint) rewardForSuccessfulProphecies; //stores the ether value of each successful kreshmoi. And yes, you can forget about reentrancy attacks.
    mapping (string => Kreshmoi[]) successfulKreshmoi; //key is USDETH or CPIXZA for instance
    mapping (string => Bounty[]) openBounties; 
    mapping (address => uint) refundsForUnclaimedBounties;
    mapping (address => uint) donations;
    mapping (string => string) datafeedDescriptions;
    mapping (string => uint) datafeedChangeCost;
    string [] datafeedNames;
   
    function Pythia(){
        
    }

    function() payable{
        donations[msg.sender] = msg.value;
    }

    function SetDescription(string datafeed, string description) payable{
        uint index =0;
        for(uint i =0;i<datafeedNames.length;i++){
            if(StringUtils.equal(datafeedNames[i],datafeed)){
                index = i;
                break;
            }
        }

        if(index==0){
            if(msg.value>=1)
                datafeedNames.push(datafeed);
            datafeedChangeCost[datafeed] = 1;
            datafeedDescriptions[datafeed] = description;
        }
        else if(msg.value>=datafeedChangeCost[datafeed]*2){
                datafeedNames[index] = description;
                datafeedChangeCost[datafeed] *=2;
                datafeedDescriptions[datafeed] = description;
        }
    }

    function GetDatafeedNameChangeCost(string datafeed) returns (uint){
        if(datafeedChangeCost[datafeed]==0){
            return 1;
        }
        return datafeedChangeCost[datafeed]*2;
    }

    function GetDescriptionByName(string datafeed) returns (string){
        return datafeedDescriptions[datafeed];
    }

    function GetDescriptionByIndex(uint index) returns (string){
        if(index<0 || index > datafeedNames.length){
         Debugging("Index out of bounds");
        }
        return datafeedNames[index];
    }

    function PostBounty(string datafeed, uint16 maxBlockRange,uint maxValueRange,uint8 requiredSampleSize,uint8 decimalPlaces) payable{

        if(msg.value/requiredSampleSize<1) {
            BountyPostFailed(datafeed,msg.sender,"ether reward too small");
            return;
        }

        if(requiredSampleSize<2) {
             BountyPostFailed(datafeed,msg.sender,"At least 2 predictions for an oracle to be considered a pythia");
             return;
        }

        if(ValidateDataFeedFails(datafeed,msg.sender)){
            return;
        }

        Bounty memory bounty = Bounty({
            maxBlockRange:maxBlockRange,
            maxValueRange:maxValueRange,
            weiRewardPerOracle:msg.value/requiredSampleSize,
            requiredSampleSize:requiredSampleSize,
            decimalPlaces:decimalPlaces,
            predictions: new int64[](requiredSampleSize),
            oracles: new address [](requiredSampleSize),
            earliestBlock:0,
            poster: msg.sender
        });

        if(openBounties[datafeed].length>20){
            address refundAddress = openBounties[datafeed][0].poster;
            uint refund = openBounties[datafeed][0].weiRewardPerOracle*openBounties[datafeed][0].requiredSampleSize;
            refundsForUnclaimedBounties[refundAddress]+=refund*10/9; //spam prevention penalty

            for(uint i =0;i<openBounties[datafeed].length-1;i++){
                openBounties[datafeed][i] = openBounties[datafeed][i+1];
            }
            uint lastIndex = openBounties[datafeed].length-1;
            openBounties[datafeed][lastIndex] = bounty;
        }
        else
           openBounties[datafeed].push(bounty);

        BountyPosted (msg.sender,datafeed,bounty.weiRewardPerOracle); 
    }
    
    function GetBountyReward() returns (uint){
        return rewardForSuccessfulProphecies[msg.sender];
    }

    function OfferKreshmoi(string datafeed,int64 value){

        Bounty [] bounties = openBounties[datafeed];

        for( uint i =0;i<bounties.length;i++){
            bool finalKreshmoi = bounties[i].predictions.length == bounties[i].requiredSampleSize-1;

            if(bounties[i].earliestBlock==0 || block.number - uint(bounties[i].earliestBlock)>uint(bounties[i].maxBlockRange)) //reset stale bounties
            {
               ClearBounty(datafeed,i,"Max block range exceeded. All previous bounty hunters have been erased. Bounty reset at current block.");
            }

            int128[] memory range = new int128[](3);//0 = smallest,1 = largest,2 = average value
            if(openBounties[datafeed][i].predictions.length>0)
            {
                range[0] = openBounties[datafeed][i].predictions[0];
                range[1] = openBounties[datafeed][i].predictions[0];
            }
            else
            {
                range[0] = 0;
                range[1] = 0;    
            }
            for(uint j =1;j<openBounties[datafeed][i].predictions.length;j++){
                range[3] += openBounties[datafeed][i].predictions[j];
                if(range[0]<openBounties[datafeed][i].predictions[j])
                    range[0] = openBounties[datafeed][i].predictions[j];
                if(range[1]>openBounties[datafeed][i].predictions[j])
                       range[1] = openBounties[datafeed][i].predictions[j];
            }
            if(value>range[1])
                range[1]= value;

            if(uint(range[1]-range[0])>openBounties[datafeed][i].maxValueRange)
            {
                ClearBounty(datafeed,i,"The kreshmoi offered exceeded the maximum allowable range for this bounty. All previous bounty hunters have been erased. Bounty reset at current block.");
            }

            openBounties[datafeed][i].predictions.push(value);
            openBounties[datafeed][i].oracles.push(msg.sender);
            
            if(finalKreshmoi){
                range[2]+=value;
                range[2]/=openBounties[datafeed][i].requiredSampleSize;
                successfulKreshmoi[datafeed].push(Kreshmoi({
                    blockRange: uint16(block.number - openBounties[datafeed][i].earliestBlock),
                    decimalPlaces:openBounties[datafeed][i].decimalPlaces,
                    value: int64(range[2]),
                    sampleSize:openBounties[datafeed][i].requiredSampleSize,
                    valueRange:uint(range[1]-range[0]),
                    bountyPoster:openBounties[datafeed][i].poster
                }));
                
                delete openBounties[datafeed][i];
                for(j= i;j<openBounties[datafeed].length-1;j++){
                    openBounties[datafeed][j] = openBounties[datafeed][j+1];
                }
                ProphecyDelivered(datafeed);
            }
        }
        KreshmoiOffered(msg.sender,datafeed);
    }

    function GetKreshmoi(string datafeed) returns (int64[]) {
        int64 [] memory values = new int64[](successfulKreshmoi[datafeed].length);
        for(uint i =0;i<successfulKreshmoi[datafeed].length;i++){
            values[i] = successfulKreshmoi[datafeed][i].value;
        }
        return values;
    }

    function ClearBounty(string datafeed, uint index, string reason) internal{
                openBounties[datafeed][index].earliestBlock = block.number;
                delete openBounties[datafeed][index].predictions;
                delete openBounties[datafeed][index].oracles;
                BountyCleared(datafeed,index,reason);
    }

    function ValidateDataFeedFails(string datafeed, address sender) internal returns(bool){
       bytes memory chararray = bytes(datafeed);
        if(chararray.length>10) {
            BountyPostFailed( datafeed,  sender, "datafeed name must contain at most 10 characters");
            return true;
        }

        if(chararray.length<3) {
            BountyPostFailed( datafeed,  sender, "datafeed name must contain at least 3 characters");
            return true;
        }

        string memory validString = "ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789";
        bytes memory validCharacterSet = bytes(validString);
        Debugging(datafeed);
        for(uint i = 0;i<chararray.length;i++){
            bool existsInValidSet = false;
            for(uint j =0;j<36;j++)
            {

                if(chararray[i]==validCharacterSet[j])
                    existsInValidSet= true;
            }
            if(!existsInValidSet){
                BountyPostFailed(datafeed, sender,"Characters must be uppercase alphanumeric.");
                return true;
            }
        }
        return false;
    }
    event Debugging(string message);
    event DebuggingUINT(string message,uint additional);
    event BountyPostFailed(string datafeed, address from, string reason);
    event BountyCleared(string datafeed, uint index, string reason);
    event BountyPosted (address from, string datafeed, uint rewardPerOracle);
    event KreshmoiOffered (address from, string datafeed);
    event ProphecyDelivered (string datafeed);
}