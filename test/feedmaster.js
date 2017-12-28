var feedMaster = artifacts.require("../contracts/FeedMaster.sol");

contract('FeedMaster', function (accounts) {

    describe("push new feed, get ID, use ID to get details", () => {
        var feedMasterInstance;

        before(() => {
            feedMaster.deployed().then(instance => feedMasterInstance = instance);
        });

        it("should push new feed", () => {

            return feedMasterInstance.pushNewFeed(4, 5, "ETHZAR", "ether rand exchange rate", { from: accounts[0], value: 400 })
                .then(() => {
                    return feedMasterInstance.getIDsForFeed.call("ETHZAR");
                }).then((result) => {
                    assert.equal(result.length, 1);
                    var idOfEthZar = parseInt(result[0]);
                    return feedMasterInstance.getFeedById.call(result[0]);
                }).then((detail) => {
                    console.log(`feedDetail: \n ${JSON.stringify(detail)}`);
                });
        });


        it("should fail when not sending ether", () => {
          //TODO: look up on truffle how to test for throws: http://truffleframework.com/tutorials/testing-for-throws-in-solidity-tests
        });
    });

});