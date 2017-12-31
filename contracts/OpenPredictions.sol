pragma solidity ^0.4.18;
import "./FeedMaster.sol";
import "./AccessRestriction.sol";

contract OpenPredictions is AccessRestriction {
    
    struct Prediction {
        uint value;
        uint feedId;
        uint blocknumber;
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
            blocknumber: block.number
        });

        predictions[feedId].push(prediction);
    }
}