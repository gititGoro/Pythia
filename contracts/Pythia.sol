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
import "./AccessRestriction.sol";

contract Pythia is AccessRestriction{

    function Pythia(){
        
    }

    //A kreshmoi is an ancient Greek word meaning an utterance issued by an oracle.
    //In our decentralized oracle, Pythia, Kreshmoi will be the name of the data structure 
    //representing a successful "utterance" on a given datafeed.
    struct Kreshmoi{
    uint16 blockRange;
    uint8 decimalPlaces;// floats don't exist in solidity (yet)
    int64 value;
    uint8 sampleSize;
    uint valueRange;
    address bountyPoster;
    }

    struct Bounty{
        uint16 maxBlockRange;
        uint earliestBlock;
        uint weiRewardPerOracle;
        uint8 requiredSampleSize;
        uint maxValueRange;
        address[] oracles;
        int64 [] predictions;
        uint8 decimalPlaces;
    }

    mapping (address => uint) rewardForSuccessfulProphecies; //stores the ether value of each successful kreshmoi. And yes, you can forget about reentrancy attacks.
    mapping (string => Kreshmoi[]) prophecies; //key is USDETH or CPIXZA for instance
    mapping (string => Bounty[]) openBounties; 
    
    function PostBounty(string datafeed, uint16 maxBlockRange,uint maxValueRange,uint8 requiredSampleSize,uint8 decimalPlaces) payable{
        if(msg.value/requiredSampleSize<1)
            throw;
        
        openBounties[datafeed].push(Bounty({
            maxBlockRange:maxBlockRange,
            maxValueRange:maxValueRange,
            weiRewardPerOracle:msg.value/requiredSampleSize,
            requiredSampleSize:requiredSampleSize,
            decimalPlaces:decimalPlaces,
            predictions: new int64[](0),
            oracles: new address [](0),
            earliestBlock:0
        }));

        BountyPosted (msg.sender,datafeed);
    }
    
    event BountyPosted (address from, string datafeed);
}