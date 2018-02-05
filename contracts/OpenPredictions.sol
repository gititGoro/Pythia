pragma solidity ^0.4.18;
import "./FeedMaster.sol";
import "./AccessRestriction.sol";
import "./libraries/circularBuffer.sol";

contract OpenPredictions is AccessRestriction {
    using CircularBufferLib for CircularBufferLib.PredictionRing;

    event WithdrawalProcessed(address account, uint amount); 
    
    struct BurnQueueItem {
        address[] addressesToBurn;
        uint amount;
    }

    FeedMaster feedMaster;
    address judgeAddress;
    mapping (uint => CircularBufferLib.PredictionRing) public predictions;
    mapping (address => uint) deposits;
    mapping (address => uint) burntDeposits; //penalty for spamming
    uint predictionRBufferSize;
    BurnQueueItem[] burnQueue;

    function setDependencies (address judge, address feedMasterAddress, uint predictionRingSize) onlyOwner public {
        judgeAddress = judge;
        feedMaster = FeedMaster (feedMasterAddress);
        predictionRBufferSize = predictionRingSize;
    }

    function resetPredictionIterator(uint feedId, address caller) public {
        predictions[feedId].resetIterator(caller);
    }

    function movePredictionIterator(uint feedId, address caller) public {
        predictions[feedId].moveIterator(caller);
    }

    function movePredictionIteratorBackwards (uint feedId, address caller) public {
        predictions[feedId].moveIteratorBackwards(caller);
    }

    function getCurrentIterator (uint feedId, address caller) public view returns (uint) {
        return predictions[feedId].iterator[caller];
    }

    function getCurrentPredictionValue (uint feedId, address caller) public view returns (uint, address, uint) {
       return predictions[feedId].getCurrentValue(caller);
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

    function deleteCurrentPrediction (uint feedId, address caller) public {
            predictions[feedId].deleteCurrentPrediction(caller);
    }

    function isCurrentPredictionEmpty(uint feedId, address caller) public view returns (bool) {
            return predictions[feedId].isEmpty(caller);
    }

    function getNextIndexForFeed(uint feedId) public view returns (uint index) {
        return predictions[feedId].nextIndex;
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

    function queueBurnDeposits (address[] oracles, uint amount) public {
            require (msg.sender == judgeAddress);
           
            BurnQueueItem memory item = BurnQueueItem({
                addressesToBurn:oracles,
                amount:amount
            });
            burnQueue.push(item);
    }

    function advanceBurnQueue(uint numberOfItems) public {
        numberOfItems = numberOfItems > burnQueue.length ? burnQueue.length : numberOfItems;
        for (numberOfItems--;numberOfItems>=0;numberOfItems--) {
            for (uint j = 0; j<burnQueue[numberOfItems].addressesToBurn.length;j++) {
               deposits[burnQueue[numberOfItems].addressesToBurn[j]] -= burnQueue[numberOfItems].amount;
            }
            burnQueue.length--;
        }   
    }

    function withdraw(uint amountToWithdraw) public {
        require(burnQueue.length == 0); //can't withdraw until failed deposits have been burnt
        amountToWithdraw = deposits[msg.sender] > amountToWithdraw?
            amountToWithdraw:deposits[msg.sender];

        if (deposits[msg.sender] >= amountToWithdraw)
          deposits[msg.sender] -= amountToWithdraw;
        WithdrawalProcessed(msg.sender, amountToWithdraw);
        msg.sender.transfer(amountToWithdraw);
    }
}