pragma solidity ^0.4.18;
import "./FeedMaster.sol";
import "./AccessRestriction.sol";
import "./libraries/circularBuffer.sol";

contract OpenPredictions is AccessRestriction {
    using CircularBufferLib for CircularBufferLib.PredictionRing;

    event WithdrawalProcessed(address account, uint amount); 
    
    FeedMaster feedMaster;
    address judgeAddress;
    mapping (uint => CircularBufferLib.PredictionRing) predictions;
    mapping (address => uint) deposits;
    mapping (address => uint) burntDeposits; //penalty for spamming
    uint predictionRBufferSize;

    function setDependencies (address judge, address feedMasterAddress, uint predictionRingSize) onlyOwner public {
        judgeAddress = judge;
        feedMaster = FeedMaster (feedMasterAddress);
        predictionRBufferSize = predictionRingSize;
    }

    function placePrediction(uint feedId, uint value) public payable {
        require(feedMaster.isValidFeed(feedId));
        require(feedMaster.getRewardByFeedId(feedId) <= msg.value);

        deposits[msg.sender] += msg.value;
        if (predictions[feedId].bufferSize == 0) {
            predictions[feedId].init(predictionRBufferSize);
        }

         predictions[feedId].insertPrediction(value, msg.sender);
    }

    function getLastIndexForFeed(uint feedId) public view returns (uint index) {
        return predictions[feedId].oldestIndex;
    }

    function getPredictionOracleForFeedIdAtIndex(uint feedId, uint index) public view returns (address) {
        return predictions[feedId].oracles[index];    
    }

    function getPredictionValueForFeedIdAtIndex (uint feedId, uint index) public view returns (uint) {
        return predictions[feedId].values[index];    
    }

    function validateBlockNumberForFeedIdAtIndex (uint feedId, uint index, uint cutoffblock) public view returns (bool) {
          return predictions[feedId].blocknumbers[index]>cutoffblock; 
    }

    function getDepositForOracle (address oracle) public view returns (uint) {
            return deposits[oracle];
    }

    function burnDeposits (address[] oracles, uint amount) public {
            require (msg.sender == judgeAddress);
            for (uint i = 0; i < oracles.length;i++) {
                uint amountToBurn = amount > deposits[oracles[i]] ? deposits[oracles[i]] : amount;
                deposits[oracles[i]] -= amountToBurn;
                burntDeposits[oracles[i]] += amountToBurn;
            }
    }

    function withdraw(uint amountToWithdraw) public {
        amountToWithdraw = deposits[msg.sender] > amountToWithdraw?
            amountToWithdraw:deposits[msg.sender];

        if (deposits[msg.sender] >= amountToWithdraw)
          deposits[msg.sender] -= amountToWithdraw;
        WithdrawalProcessed(msg.sender, amountToWithdraw);
        msg.sender.transfer(amountToWithdraw);
    }
}