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
    mapping (uint => Prediction[]) predictions;

    function setFeedMaster(address feedMasterAddress) onlyOwner public {
        feedMaster = FeedMaster (feedMasterAddress);
    }

    function placePredictions(uint feedId, uint value) public {
        require(feedMaster.isValidFeed(feedId));

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
}