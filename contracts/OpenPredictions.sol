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

    function getPredictionsByFeedIdSinceBlock (uint feedId, uint blocknumber) public view returns (uint[] values ,address[] oracles) {
        for (uint firstIndex = predictions[feedId].length-1;i >= 0 && predictions[feedId][i].blocknumber >= blocknumber;firstIndex--) {

        }
        
        values = new uint[](predictions[feedId].length - firstIndex);
        oracles = new address[](predictions[feedId].length - firstIndex);
         
        for (uint i = firstIndex ;i < values.length; i++) {    
            values[i - firstIndex] = predictions[feedId][i].value;
            oracles[i - firstIndex] = predictions[feedId][i].oracle;
        }
    }
}