pragma solidity ^0.4.18;

import "../Pythia.sol";

contract TestRewardPythia {

    Pythia instance;

    address[] testUsers;

    function setUp(address[] users) public {
        for (uint i = 0; i < 4; i++) {
                testUsers[i] = users[i];
                instance.pushAverageFrequencyPerFeed (testUsers[4], "ETHZAR", 10); 
        }
        instance.pushPredictions("ETHZAR", testUsers[0], 1241, 2);
        instance.pushPredictions("ETHZAR", testUsers[1], 1341, 2);
        instance.pushPredictions("ETHZAR", testUsers[2], 1441, 2);
        instance.pushPredictions("ETHZAR", testUsers[3], 1541, 2);
       //function pushPredictions(string datafeed, address oracle, int64 prediction, uint8 decimalPlaces) public {
    }

    function invokeRewardPythiaSuccess (address originalSender) public {
        instance.rewardPythia("ETHZAR", 4, 10, 4000,2,10, originalSender);
    }

}