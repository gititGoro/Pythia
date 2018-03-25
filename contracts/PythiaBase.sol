pragma solidity ^0.4.17;

import "./AccessRestriction.sol";

contract PythiaBase is AccessRestriction {
   
    //A kreshmoi is an ancient Greek word meaning an utterance issued by an oracle.
    //In our decentralized oracle, Pythia, Kreshmoi will be the name of the data structure 
    //representing a successful "utterance" on a given datafeed

    struct PassiveKreshmoi {
        address oracle;
        int64 prediction;
        uint8 decimalPlaces;
        uint blockNumber;
    }

    struct Prophecy {
        int128 sumOfPredictions;
        uint8 decimalPlaces;
        uint8 sampleSize;
        uint blockNumber;
    }
    //When someone wants a kreshmoi on a particular datafeed, they'll issue
    //a bounty on that datafeed specifying how many people must achieve consensus
    //and to what degree they'll tolerate variance
    //If the requisite number is met in the specified time within the set tolerance
    //each will be rewarded equally
    //Economics: If pythia are scarce, the reward must be raised. If pythia are too frequent, the reward can drop
    //Free riding: unlikely to be a problem. Some use cases require very frequent feeds and will
    //put out a bounty often, regardless of free riding.
    //Game Theory: votes can be spoiled by offering kreshmoi out of range which
    //means that offering innacurate data is risky. After all, web services might exist
    //that occasionally offer accurate data. It will be hard to predict when this will occur
    //I'm considering requiring voters put up a deposit but I'm worried
    //that malicious actors will undermine the system by purposefully offering out of range kreshmoi 
}