pragma solidity ^0.4.17;
import "./AccessRestriction.sol";

contract FeedMaster is AccessRestriction {
    struct FeedTemplate {
        uint8 decimalPlaces;
        uint maxRange;
        string feedName;
        address owner;
        uint8 minBlockInterval;
        uint8 maxBlockInterval;
        uint creationDate; //block.timestamp of feed creation
        uint8 epochSize; // number of hours per epoch, counting from creationDate
    }
    mapping (string => uint[]) feedIDmapping;

    FeedTemplate[] feeds;

    function pushNewFeed(uint8 decimalPlaces, uint maxRange, string feedName, uint8 minInterval, uint8 maxInterval, uint8 epochSize) public {
        feedIDmapping[feedName].push(feeds.length);
        FeedTemplate memory template = FeedTemplate({
            decimalPlaces:decimalPlaces,
            maxRange: maxRange,
            feedName:feedName,
            minBlockInterval:minInterval,
            maxBlockInterval:maxInterval,
            creationDate: block.timestamp,
            epochSize:epochSize,
            owner: msg.sender
            });

        feeds.push(template);
    }

    function getIDsForFeed(string feedName) public view returns (uint[]) {
        return feedIDmapping[feedName];
    }
}