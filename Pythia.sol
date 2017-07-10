pragma solidity ^0.4.11;
//TODO: read security stuff
//TODO: when placing a bid, do an inplace sort so that the final request doesn't run out of gas
//SECURITY: Always change all variables and only as the very last act, transfer ether.
//SECURITY: perform all bookkeeping on the same scope level in case malicious actor gets stack to 1024 and then you try to do something with function call and 
//it isn't atomic
//SECURITY: use invariants to trigger safe mode if any of the invariants become inconsistent.
//Breakthrough: It doesn't matter than the state is viewable to all. What matters is that it's private to contracts.
//TODO: add modifier to allow owner to disable the entire contract in case I want to launch a newer version.
//TODO: make a withdrawal function
import "./AccessRestriction.sol";

contract Pythia is AccessRestriction{

    enum KreshmoiDataType{
        INT,MICRO
    }

    //A kreshmoi is an ancient Greek word meaning an utterance issued by an oracle.
    //In our decentralized oracle, Pythia, Kreshmoi will be the name of the data structure representing an "utterance" on a given datafeed.
    struct Kreshmoi{
    uint blockNumber;
    KreshmoiDataType dataType;
    int32 value_int;
    int64 value_micro; // each unit of this represents 1 millionth of a unit
   
    address sender;
    }
    mapping (address => uint) rewardForSuccessfulProphecies; //stores the ether value of each successful kreshmoi. And yes, you can forget about reentrancy attacks.
    mapping (string => Kreshmoi[]) prophecies; //key is USDETH or CPIXZA for instance
    mapping (address => uint64) successfulHistory; //TODO: make sure dynamic array
    //if a datafeed is requested and doesn't exist, ("name",false) is created, otherwise ("name",true) is set
    mapping (string => bool) existentDataFeeds; 

    function SubmitIntegerProphecy(string feedName, int32 value ) notBlacklisted returns (string result){
        uint length = prophecies[feedName].length;
        if(length >0 && prophecies[feedName][length-1].dataType!=KreshmoiDataType.INT){
            result = "invalid datatype for feed. Expected decimal but was int";
            }

        result = "success";
        prophecies[feedName].length+=1;
        prophecies[feedName][length].blockNumber = block.number;
        prophecies[feedName][length].value_int =value;
        prophecies[feedName][length].dataType =KreshmoiDataType.INT;
        prophecies[feedName][length].sender =msg.sender;

        ProphecySubmission(msg.sender,feedName);
    }

   function SubmitDecimalProphecy(string feedName, int64 value ) notBlacklisted returns (string result){
        uint length = prophecies[feedName].length;
           if(length >0 && prophecies[feedName][length-1].dataType!=KreshmoiDataType.INT){
            result = "invalid datatype for feed. Expected int but was decimal";
            }     
        result = "success";

        prophecies[feedName].length+=1;
        prophecies[feedName][length].blockNumber = block.number;
        prophecies[feedName][length].value_micro =value;
        prophecies[feedName][length].dataType =KreshmoiDataType.MICRO;
        prophecies[feedName][length].sender =msg.sender;

        ProphecySubmission(msg.sender,feedName);
    }

    function RequestInteger(string feedName, uint8 maxSampleSize, int32 acceptableRange, uint16 minSuccesses) payable returns (int32 result){
        uint8 prophecyLength;
        uint8 actualSampleSize;
        prophecyLength = prophecies[feedName].length>255?255:uint8(prophecies[feedName].length);
        if(prophecyLength==0 || maxSampleSize>50 || msg.value<maxSampleSize)//last condition because each winner should get at least 1 wei
            {
                return;
            }
        
        actualSampleSize = (block.number- prophecies[feedName][prophecyLength -1].blockNumber)>255?255:
            uint8(block.number- prophecies[feedName][prophecyLength -1].blockNumber);

        Kreshmoi[] memory filtered = Filter(prophecies[feedName],actualSampleSize,filterLatest);
                            filtered = Reduce(filtered,FilterOutDuplicateUsers); 
                            filtered = ThresholdMinSuccesses(filtered, minSuccesses);   
        
        require(GetRange(filtered)<=acceptableRange);
        
        for(uint i = 0; i<(filtered.length>255?255:filtered.length); i++){
            successfulHistory[filtered[i].sender]++;
            result = result + filtered[i].value_int;
        }
        result = result/int32(filtered.length);

        uint rewardPerWinner = msg.value/filtered.length; //rewardperWinner
        for(i=0;i<filtered.length;i++){
            rewardForSuccessfulProphecies[filtered[i].sender]+=rewardPerWinner;
        }
    }

    function GetRange(Kreshmoi [] memory kreshmoi) internal returns (int32){
        int32[] memory biggestSmallest = new int32[](2);
        for(uint i =0;i<kreshmoi.length;i++){
            if(kreshmoi[i].value_int<biggestSmallest[0]){
                biggestSmallest[0] = kreshmoi[i].value_int;
            }
            if(kreshmoi[i].value_int>biggestSmallest[1]){
                biggestSmallest[1] = kreshmoi[i].value_int;
            }
        }
        return biggestSmallest[1] - biggestSmallest[0];
    }

    function ThresholdMinSuccesses(Kreshmoi [] memory initialKreshmoi, uint16 minSuccesses) internal returns (Kreshmoi[] memory){
        bool [] memory valid = new bool[] (initialKreshmoi.length);
        uint validCount  = 0;
        for(uint i =0;i<valid.length;i++){
            if(successfulHistory[initialKreshmoi[i].sender]>=minSuccesses)
                {
                    valid[i]= true;
                    validCount++;
                }
        }

        Kreshmoi[] memory threshold = new Kreshmoi[](validCount);
        validCount = 0;
        for(i =0;i<initialKreshmoi.length;i++){
            if(valid[i]){
                threshold[validCount]= initialKreshmoi[i];
                validCount++;
            }
        }
        return threshold;
    }

    function filterLatest (Kreshmoi memory kreshmoi, uint8 blockAge) internal returns (bool){
            return((block.number- kreshmoi.blockNumber)>255?255:
                uint8(block.number- kreshmoi.blockNumber))>blockAge;
    }

    function FilterOutDuplicateUsers(Kreshmoi[] memory accumulator, Kreshmoi memory current) internal returns (Kreshmoi[] memory){  
       Kreshmoi [] memory potentialNewAccumulator = new Kreshmoi[](accumulator.length+1);
        for(uint i =0;i<accumulator.length;i++){
            if(current.sender == accumulator[i].sender)
                return accumulator; 
                potentialNewAccumulator[i] = accumulator[i];
        }
        potentialNewAccumulator[accumulator.length] = current;
        return potentialNewAccumulator;
    }

    function Reduce (Kreshmoi[] initialArray, function (Kreshmoi [] memory ,Kreshmoi memory) returns (Kreshmoi [] memory) reducer) internal returns(Kreshmoi[]){
      Kreshmoi [] memory accumulator = new Kreshmoi[](0);
        for(uint i =0;i<initialArray.length;i++){
              accumulator = reducer(accumulator, initialArray[0]);
        }
        return accumulator;
    }

    function Filter(Kreshmoi[] memory kreshmoi,uint8 initialValue, function(Kreshmoi memory, uint8) returns (bool) predicate ) internal returns (Kreshmoi[]){
             bool[] memory chosen = new bool[](kreshmoi.length);
             uint8 actualLength =0;

            for(uint i =0; i<kreshmoi.length;i++){
                if(predicate(kreshmoi[i],initialValue)){
                    chosen[i] = true;
                    actualLength++;
                }
            }
            
            Kreshmoi[] memory actual =new Kreshmoi[](actualLength);
            actualLength=0;
            for(i =0;i<chosen.length;i++){
                if(chosen[i]){
                    actual[actualLength++] = kreshmoi[i];
                }
            }
            return actual;
        }

    modifier notBlacklisted() { //wallet or contract permanently blacklisted. If this was a mistake the user will have to start their own pythia with blackjack and hookers.
          require(successfulHistory[msg.sender] >=0);
        _;
    }

    event ProphecySubmission(address from, string datafeed );

}