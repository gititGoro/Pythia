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
       openPredictions.resetPredictionIterator(feedId, msg.sender);
       openPredictions.movePredictionIteratorBackwards(feedId, msg.sender);
       uint[3] memory rangeOfPredictions = [2**256-1,0,0]; 
       
       for (uint8 i = requiredNumberOfOracles*10;i > 0 && requiredNumberOfOracles > 0; i--) { //if one address spams too much then no one is rewarded.
            if (openPredictions.isCurrentPredictionEmpty(feedId,msg.sender)) {
                  openPredictions.movePredictionIteratorBackwards(feedId, msg.sender);
                  continue;
            }
            uint currentIterator = openPredictions.getCurrentIterator(feedId, msg.sender);
            if (!openPredictions.validateBlockNumberForFeedIdAtIndex(feedId,currentIterator,lastBlock)) { //prediction too old
                continue;
            }

            address currentOracle = openPredictions.getPredictionOracleForFeedIdAtIndex(feedId, currentIterator);
            
            for (uint j = 0; j<oracles.length;j++) {
                if (oracles[j]==currentOracle || oracles[j] == address(0))
                    continue;
            }
            //next we check if the oracle has skin in the game
            if (feedMaster.getRewardByFeedId(feedId)/requiredNumberOfOracles > openPredictions.getDepositForOracle(currentOracle)) {
                continue;
            }
            oracles[i] = currentOracle;
            values[i] = openPredictions.getPredictionValueForFeedIdAtIndex(feedId, currentIterator);
            if (values[i]<rangeOfPredictions[0]) {
                rangeOfPredictions[0] = values[i];
            } else if (values [i] > rangeOfPredictions[1]) {
                rangeOfPredictions[1] = values[i];
            }
            rangeOfPredictions[2] += values[i];
            requiredNumberOfOracles--;
            openPredictions.deleteCurrentPrediction(feedId, msg.sender); //ensures oracle can't be rewarded eternally
            openPredictions.movePredictionIteratorBackwards(feedId, msg.sender);
       }
        if (requiredNumberOfOracles > 0) //either there are too few predictions or someone is spamming the feed.
            return;

       if (rangeOfPredictions[1] - rangeOfPredictions[0] > feedMaster.getMaxRangeByFeedId (feedId)) {
           //EVENT NOT SUCCESS
            openPredictions.queueBurnDeposits (oracles, feedMaster.getRewardByFeedId(feedId)/requiredNumberOfOracles);
            return;
       }

        kreshmoiHistory.logUnrewardedPythiaKreshmoi(rangeOfPredictions[2], feedId, oracles);
        refunds[msg.sender] -= msg.value; // success means no refund.
    }
}