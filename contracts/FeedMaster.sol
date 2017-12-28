pragma solidity ^0.4.18;
import "./AccessRestriction.sol";

contract FeedMaster is AccessRestriction {
    struct FeedTemplate {
        uint reward; //wei
        uint8 decimalPlaces;
        uint8 numberOfOracles;
        string feedName;
        string description;
    }

    uint balance;
    mapping (string => uint[]) feedIDmapping;

    FeedTemplate[] feeds;

    function pushNewFeed(uint8 decimalPlaces, uint8 numberOfOracles, string feedName, string description) public payable {
            require (msg.value>0);
            balance += msg.value;
            feedIDmapping[feedName].push(feeds.length);
            FeedTemplate memory template = FeedTemplate({
                reward: msg.value,
                decimalPlaces:decimalPlaces,
                numberOfOracles: numberOfOracles,
                feedName:feedName,
                description:description
            });

            feeds.push(template);
    }

    function getIDsForFeed(string feedName) public view returns (uint[]) {
        return feedIDmapping[feedName];
    }

    function getFeedById (uint id) public view returns (string feedName, uint reward, uint8 numberOfOracles, uint8 decimalPlaces, string description) {
        feedName = feeds[id].feedName;
        reward = feeds[id].reward;
        numberOfOracles = feeds[id].numberOfOracles;
        decimalPlaces = feeds[id].decimalPlaces;
        description = feeds[id].description;
    }

    function withDraw() public {
        uint balanceToSend = balance;
        balance = 0;
        owner.transfer(balanceToSend);
    }
}