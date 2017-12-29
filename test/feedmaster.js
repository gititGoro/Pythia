let feedMaster = artifacts.require("../contracts/FeedMaster.sol");
let test = require("./helpers/async.js").test;
let expectThrow = require("./helpers/expectThrow.js").handle;

contract('FeedMaster', function (accounts) {

    describe("push new feed, get ID, use ID to get details", () => {
        var feedMasterInstance;

        before(() => {
            feedMaster.deployed().then(instance => feedMasterInstance = instance);
        });


        test("should push new feed", async () => {
            await feedMasterInstance.pushNewFeed(4, 5, "ETHZAR", "ether rand exchange rate", { from: accounts[0], value: 400 });
            let result = await feedMasterInstance.getIDsForFeed.call("ETHZAR");
            assert.equal(result.length, 1);
            let idOfEthZar = parseInt(result[0]);
            let detail = await feedMasterInstance.getFeedById.call(result[0]);
            assert.equal(detail[0], "ETHZAR", "feedname");
            assert.equal(detail[1], "400", "reward");
            assert.equal(detail[2], "4", "decimal places");
            assert.equal(detail[3], "5", "number of oracles");
            assert.equal(detail[4], "ether rand exchange rate", "description");
        });

        test("should fail when not sending ether", async () => {
            await expectThrow(feedMasterInstance.pushNewFeed(4, 5, "ETHZAR", "ether rand exchange rate", { from: accounts[0] }));
        });
    });
});