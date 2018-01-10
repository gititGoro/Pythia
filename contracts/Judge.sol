pragma solidity ^0.4.18;
import "./FeedMaster.sol";
import "./AccessRestriction.sol";
import "./OpenPredictions.sol";

contract Judge is AccessRestriction {
    uint placeholder;

    OpenPredictions openPredictions;
    FeedMaster feedMaster;
    mapping (address => uint) refunds;

    function setDependencies(address feedMasterAddress, address openPredictionsAddress) onlyOwner public {
        feedMaster = FeedMaster (feedMasterAddress);
        openPredictions = OpenPredictions (openPredictionsAddress);
    }

    function scanPredictions(uint lastBlock, uint feedId) public payable {
       refunds[msg.sender] = msg.value; //in case this crashes, sender can claim refund
       if (msg.value < feedMaster.getRewardByFeedId(feedId)) {
           //EVENT not enough ether
           return;
       }
       uint8 requiredNumberOfOracles = feedMaster.getNumberOfOracles(feedId);
       address[] memory oracles = new address[](requiredNumberOfOracles);
       uint[] memory values = new uint[](requiredNumberOfOracles);
       uint i = openPredictions.getLastIndexForFeed(feedId);
       uint[2] memory rangeOfPredictions = [2**256-1,0]; 
       for (;i>0 && requiredNumberOfOracles>0;i--) {
            address currentOracle = openPredictions.getPredictionOracleForFeedIdAtIndex(feedId,i);
            
            for (uint j = 0; j<oracles.length;j++) {
            if (oracles[j]==currentOracle)
                continue;
            }
            oracles[i] = currentOracle;
            values[i] = openPredictions.getPredictionValueForFeedIdAtIndex(feedId,i);
            if (values[i]<rangeOfPredictions[0]) {
                rangeOfPredictions[0] = values[i];
            } else if (values [i] > rangeOfPredictions[1]) {
                rangeOfPredictions[1] = values[i];
            }
            requiredNumberOfOracles--;
       }

        if (!openPredictions.validateBlockNumberForFeedIdAtIndex(feedId,i+1,lastBlock)) {
           return;
        }

       if (rangeOfPredictions[1] - rangeOfPredictions[0] > feedMaster.getMaxRangeByFeedId (feedId)) {
           //EVENT NOT SUCCESS
           //mark oracle deposits not refunded
            return;
       }


        //get requiredNumber of oracles
        //get Last oracle and if unique get last value, increment index
        //increment index
        //after correct number of indexes, 

        refunds[msg.sender] -= msg.value; // success means no refund.
    }
}