pragma solidity ^0.4.18;
import "./AccessRestriction.sol";

contract FeedMaster is AccessRestriction {
    struct FeedTemplate {
        uint reward; //wei
        uint8 decimalPlaces;
        uint8 numberOfOracles;
        uint maxRange;
        string feedName;
        string description;
    }
    //TODO: have a way to clear out unpopular feeds
    uint balance;
    mapping (string => uint[]) feedIDmapping;

    FeedTemplate[] feeds;

    function pushNewFeed(uint8 decimalPlaces, uint8 numberOfOracles,uint maxRange, string feedName, string description) public payable {
            require (msg.value>0);
            balance += msg.value;
            feedIDmapping[feedName].push(feeds.length);
            FeedTemplate memory template = FeedTemplate({
                reward: msg.value,
                decimalPlaces:decimalPlaces,
                numberOfOracles: numberOfOracles,
                maxRange: maxRange,
                feedName:feedName,
                description:description
            });

            feeds.push(template);
    }

    function getIDsForFeed(string feedName) public view returns (uint[]) {
        return feedIDmapping[feedName];
    }

    function getFeedById (uint id) public view returns (string feedName, uint reward,  uint8 decimalPlaces, uint8 numberOfOracles, string description) {
        feedName = feeds[id].feedName;
        reward = feeds[id].reward;
        numberOfOracles = feeds[id].numberOfOracles;
        decimalPlaces = feeds[id].decimalPlaces;
        description = feeds[id].description;
    }

    function isValidFeed(uint id) public view returns (bool) {
        return id < feeds.length;
    }

    function withDraw() public {
        uint balanceToSend = balance;
        balance = 0;
        owner.transfer(balanceToSend);
    }

    function getRewardByFeedId (uint id) public view returns (uint reward) {
        reward = feeds[id].reward;
    }

     function getDecimalPlacesByFeedId (uint id) public view returns (uint8 decimalPlaces) {
         decimalPlaces = feeds[id].decimalPlaces;
    }

    function getNumberOfOracles (uint id) public view returns (uint8 numberOfOracles) {
         numberOfOracles = feeds[id].numberOfOracles;
    }

    function getMaxRangeByFeedId (uint id) public view returns (uint range) {
        range = feeds[id].maxRange;
    }

}