pragma solidity ^0.4.11;
//TODO: see common patters for restricting access so that bids can't be inspected without going through request function
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
    string datafeedKey; //eg. USDETH
    KreshmoiDataType dataType;
    int32 value_int;
    int64 value_micro; // each unit of this represents 1 millionth of a unit
   
    address sender;
    uint64 range_micro;
    }
    mapping (address => uint) rewardForSuccessfulProphecies; //stores the ether value of each successful kreshmoi. And yes, you can forget about reentrancy attacks.
    mapping (string => Kreshmoi[]) prophecies;
    mapping (address => uint64) successfulHistory; //TODO: make sure dynamic array
    //if a datafeed is requested and doesn't exist, ("name",false) is created, otherwise ("name",true) is set
    mapping (string => bool) existentDataFeeds; 

    function SubmitIntegerProphecy(string feedName, int32 value, uint64 range_micro ) notBlacklisted returns (string result){
        uint length = prophecies[feedName].length;
        if(length >0 && prophecies[feedName][length-1].dataType!=KreshmoiDataType.INT){
            result = "invalid datatype for feed. Expected decimal but was int";
            }

        result = "success";
        prophecies[feedName].length+=1;
        prophecies[feedName][length].blockNumber = block.number;
        prophecies[feedName][length].datafeedKey =feedName;
        prophecies[feedName][length].value_int =value;
        prophecies[feedName][length].dataType =KreshmoiDataType.INT;
        prophecies[feedName][length].range_micro =range_micro;
        prophecies[feedName][length].datafeedKey =feedName;
        prophecies[feedName][length].sender =msg.sender;

        ProphecySubmission(msg.sender,feedName);
    }

   function SubmitDecimalProphecy(string feedName, int64 value, uint64 range_micro ) notBlacklisted returns (string result){
        uint length = prophecies[feedName].length;
           if(length >0 && prophecies[feedName][length-1].dataType!=KreshmoiDataType.INT){
            result = "invalid datatype for feed. Expected int but was decimal";
            }     
        result = "success";

        prophecies[feedName].length+=1;
        prophecies[feedName][length].blockNumber = block.number;
        prophecies[feedName][length].datafeedKey =feedName;
        prophecies[feedName][length].value_micro =value;
        prophecies[feedName][length].dataType =KreshmoiDataType.MICRO;
        prophecies[feedName][length].range_micro =range_micro;
        prophecies[feedName][length].datafeedKey =feedName;
        prophecies[feedName][length].sender =msg.sender;

        ProphecySubmission(msg.sender,feedName);
    }

    function RequestInteger(string feedName, uint8 maxSampleSize, int32 acceptableDrift, uint16 minSuccesses) payable returns (int32 result){
               uint8 [] memory localVars = new uint8[](4);//prophecyLength,actualSampleSize,blockAge,existsInSample
                                            //rewardPerWinner,
                localVars[0] = prophecies[feedName].length>255?255:uint8(prophecies[feedName].length);
                if(localVars[0]==0 || maxSampleSize>50 || msg.value<maxSampleSize)
                    {
                        return;
                    }
             
                address [] memory actualSample = new address[](maxSampleSize);
                localVars[2] = (block.number- prophecies[feedName][localVars[0] -1].blockNumber)>255?255:
                    uint8(block.number- prophecies[feedName][localVars[0] -1].blockNumber);

                for(uint i = localVars[0]-1; i>0; i--){
                    if((block.number - prophecies[feedName][i].blockNumber)>255 || 
                    uint8(block.number - prophecies[feedName][i].blockNumber)> localVars[2])
                       break;

                     localVars[3] = 0;
                    for(uint j=0;j< localVars[1];j++){
                        if(actualSample[j]==prophecies[feedName][i].sender){
                             localVars[3] = 1;
                            break;
                            }
                    }
                    if(localVars[3]==1) 
                        continue;

                    if(successfulHistory[prophecies[feedName][i].sender]<minSuccesses)
                        continue;arra
                        
                    actualSample[localVars[1]] = prophecies[feedName][i].sender;
                    localVars[1]++;
                    successfulHistory[prophecies[feedName][i].sender]++;

                   if(prophecies[feedName][i].value_int-result>acceptableDrift)
                      throw;
                    
                    result = (result + prophecies[feedName][i].value_int)/localVars[1];
                }
                if(localVars[1]==0) //safety against funny bugs
                   return;

               uint rewardPerWinner = msg.value/localVars[1]; //rewardperWinner
                for(i=0;i<localVars[1];i++){
                    rewardForSuccessfulProphecies[actualSample[i]]+=rewardPerWinner;
                }
    }

    function Filter(Kreshmoi[] storage kreshmoi, function(Kreshmoi storage) returns (bool) predicate ) internal returns (Kreshmoi[]){
             Kreshmoi[] storage chosen;
            for(uint i =0; i<kreshmoi.length;i++){
                if(predicate(kreshmoi[i]))
                    chosen.push(kreshmoi[i]);
            }
            Kreshmoi[] memory actual =new Kreshmoi[](chosen.length);
            for(i =0;i<chosen.length;i++){
                actual[i] = chosen[i];
                delete chosen[i];
                chosen.length--;
            }
            return actual;
        }

    modifier notBlacklisted() { //wallet or contract permanently blacklisted. If this was a mistake the user will have to start their own pythia with blackjack and hookers.
          require(successfulHistory[msg.sender] >=0);
        _;
    }

    event ProphecySubmission(address from, string datafeed );

}