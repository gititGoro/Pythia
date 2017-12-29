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

    describe("push multiplefeeds, get back multiple IDS", () => {
        var feedMasterInstance;

        before(() => {
            feedMaster.deployed().then(instance => feedMasterInstance = instance);
        });

        test("push multiple feeds of same type", async () => {
            await feedMasterInstance.pushNewFeed(4, 5, "ETHZAR", "ether rand exchange rate", { from: accounts[0], value: 400 });
            let idArray = await feedMasterInstance.getIDsForFeed.call("ETHZAR");
            assert.equal(idArray.length, 2, "array length 2");
            await feedMasterInstance.pushNewFeed(4, 5, "ETHZAR", "ether rand exchange rate", { from: accounts[0], value: 400 });
            idArray = await feedMasterInstance.getIDsForFeed.call("ETHZAR");
            assert.equal(idArray.length, 3, "array length 3");
            await feedMasterInstance.pushNewFeed(4, 5, "ETHZAR", "ether rand exchange rate", { from: accounts[0], value: 400 });
            idArray = await feedMasterInstance.getIDsForFeed.call("ETHZAR");
            assert.equal(idArray.length, 4, "array length 4");

            assert.notEqual(idArray[0],idArray[1]);
            assert.notEqual(idArray[1],idArray[2]);
            assert.notEqual(idArray[0],idArray[2]);
        });

        test ("push interleaved feeds of different types to test id assignment", async () => {
            await feedMasterInstance.pushNewFeed(14, 5, "USDGBP", "dollar pound", { from: accounts[0], value: 4 });
            await feedMasterInstance.pushNewFeed(14, 5, "JPYSWC", "yen swiss exchange rate", { from: accounts[0], value: 4 });
            await feedMasterInstance.pushNewFeed(14, 5, "USDGBP", "back to pound", { from: accounts[0], value: 4 });
            await feedMasterInstance.pushNewFeed(14, 5, "JPYSWC", "back to yen", { from: accounts[0], value: 4 });
            await feedMasterInstance.pushNewFeed(14, 5, "ETHZAR", "back to ether zar", { from: accounts[0], value: 4 });
            let USDGBPidArray = await feedMasterInstance.getIDsForFeed.call("USDGBP");
            assert.equal (USDGBPidArray.length, 2, "length of USDGBP array");
            assert.equal (USDGBPidArray[0], 4, "id of first USDGBP");
            assert.equal (USDGBPidArray[1], 6, "id of second USDGBP");
            
            let JPYSWCidArray = await feedMasterInstance.getIDsForFeed.call("JPYSWC");
            assert.equal (JPYSWCidArray.length, 2, "length of JPYSWC array");
            assert.equal (JPYSWCidArray[0], 5, "id of first JPYSWC");
            assert.equal (JPYSWCidArray[1], 7, "id of second JPYSWC");

            let ETHZARidArray = await feedMasterInstance.getIDsForFeed.call("ETHZAR");
            assert.equal (ETHZARidArray.length, 5, "length of ETHZAR array");
            assert.equal (ETHZARidArray[0], 0, "id of first ETHZAR");
            assert.equal (ETHZARidArray[1], 1, "id of second ETHZAR");
            assert.equal (ETHZARidArray[2], 2, "id of third ETHZAR");
            assert.equal (ETHZARidArray[3], 3, "id of fourth ETHZAR");
            assert.equal (ETHZARidArray[4], 8, "id of fifth ETHZAR");

            let detail = await feedMasterInstance.getFeedById.call(JPYSWCidArray[0]);
            assert.equal(detail[0], "JPYSWC", "feedname");
            assert.equal(detail[1], "4", "reward");
            assert.equal(detail[2], "14", "decimal places");
            assert.equal(detail[3], "5", "number of oracles");
            assert.equal(detail[4], "yen swiss exchange rate", "description");
        });

    });
});