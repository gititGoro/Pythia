pragma solidity ^0.4.18;
import "./FeedMaster.sol";
import "./AccessRestriction.sol";
import "./OpenPredictions.sol";
import "./KreshmoiHistory.sol";
import "./libraries/circularBuffer.sol";

contract Judge is AccessRestriction {
    uint placeholder;

    OpenPredictions openPredictions;
    FeedMaster feedMaster;
    KreshmoiHistory kreshmoiHistory;
    address kreshmoiHistoryAddress;
    mapping (address => uint) refunds;
    mapping (address => uint) bountyRewards;

    function setDependencies(address feedMasterAddress, address openPredictionsAddress, address kreshmoiHistoryContractAddress) onlyOwner public {
        feedMaster = FeedMaster (feedMasterAddress);
        openPredictions = OpenPredictions (openPredictionsAddress);
        kreshmoiHistoryAddress = kreshmoiHistoryContractAddress;
        kreshmoiHistory = KreshmoiHistory (kreshmoiHistoryContractAddress);
    }

    function addBountyReward (address oracle, uint bounty) public {
        require (msg.sender == kreshmoiHistoryAddress);
        bountyRewards[oracle] += bounty;
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
       uint[3] memory rangeOfPredictions = [2**256-1,0,0]; 
       for (;i>0 && requiredNumberOfOracles>0;i--) {
            address currentOracle = openPredictions.getPredictionOracleForFeedIdAtIndex(feedId,i);
            
            for (uint j = 0; j<oracles.length;j++) {
            if (oracles[j]==currentOracle)
                continue;
            }
            //next we check if the oracle has skin in the game
            if (feedMaster.getRewardByFeedId(feedId)/requiredNumberOfOracles > openPredictions.getDepositForOracle(currentOracle)) {
                continue;
            }
            oracles[i] = currentOracle;
            values[i] = openPredictions.getPredictionValueForFeedIdAtIndex(feedId,i);
            if (values[i]<rangeOfPredictions[0]) {
                rangeOfPredictions[0] = values[i];
            } else if (values [i] > rangeOfPredictions[1]) {
                rangeOfPredictions[1] = values[i];
            }
            rangeOfPredictions[2] += values[i];
            requiredNumberOfOracles--;
       }

        if (!openPredictions.validateBlockNumberForFeedIdAtIndex(feedId,i+1,lastBlock)) {
           return;
        }

       if (rangeOfPredictions[1] - rangeOfPredictions[0] > feedMaster.getMaxRangeByFeedId (feedId)) {
           //EVENT NOT SUCCESS
            openPredictions.burnDeposits (oracles, feedMaster.getRewardByFeedId(feedId)/requiredNumberOfOracles);
            return;
       }

        kreshmoiHistory.logUnrewardedPythiaKreshmoi(rangeOfPredictions[2], feedId, oracles);
        refunds[msg.sender] -= msg.value; // success means no refund.
    }
}