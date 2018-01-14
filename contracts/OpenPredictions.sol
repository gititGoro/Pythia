pragma solidity ^0.4.18;
import "./FeedMaster.sol";
import "./AccessRestriction.sol";

contract OpenPredictions is AccessRestriction {
    
    struct Prediction {
        uint value;
        uint feedId;
        uint blocknumber;
        address oracle;
    }
    
    FeedMaster feedMaster;
    address judgeAddress;
    mapping (uint => Prediction[]) predictions;
    mapping (address => uint) deposits;
    mapping (address => uint) burntDeposits; //penalty for spamming

    function setJudgeAddress (address judge) onlyOwner public {
        judgeAddress = judge;
    }

    function setFeedMaster(address feedMasterAddress) onlyOwner public {
        feedMaster = FeedMaster (feedMasterAddress);
    }

    function placePrediction(uint feedId, uint value) public payable {
        require(feedMaster.isValidFeed(feedId));
        require(feedMaster.getRewardByFeedId(feedId) <= msg.value);
        
        deposits[msg.sender] += msg.value;

        if (predictions[feedId].length > 10000) {
                predictions[feedId].length = 0; 
        }

        Prediction memory prediction = Prediction({
            value:value,
            feedId:feedId,
            blocknumber: block.number,
            oracle: msg.sender
        });

        predictions[feedId].push(prediction);
    }

    function getLastIndexForFeed(uint feedId) public view returns (uint index) {
        return predictions[feedId].length-1;
    }

    function getPredictionOracleForFeedIdAtIndex(uint feedId, uint index) public view returns (address) {
        return predictions[feedId][index].oracle;    
    }

    function getPredictionValueForFeedIdAtIndex (uint feedId, uint index) public view returns (uint) {
        return predictions[feedId][index].value;    
    }

    function validateBlockNumberForFeedIdAtIndex (uint feedId, uint index, uint cutoffblock) public view returns (bool) {
          return predictions[feedId][index].blocknumber>cutoffblock; 
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

    function withDraw(uint amountToWithdraw) public {
        amountToWithdraw = deposits[msg.sender] > amountToWithdraw?
            amountToWithdraw:deposits[msg.sender];

        if (deposits[msg.sender] <= amountToWithdraw)
          deposits[msg.sender] -= amountToWithdraw;
        msg.sender.transfer(amountToWithdraw);
    }
}