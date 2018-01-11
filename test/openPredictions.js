let openPredictions = artifacts.require("../contracts/OpenPredictions.sol");
let feedMaster = artifacts.require("../contracts/FeedMaster.sol");
let test = require("./helpers/async.js").test;
let beforeTest = require("./helpers/async.js").beforeTest;
let expectThrow = require("./helpers/expectThrow.js").handle;


contract('OpenPredictions', accounts => {
    var feedMasterInstance, openPredictionsInstance, BTCUSDID;
    before(() => {
        feedMaster.deployed()
            .then(instance => {
                feedMasterInstance = instance;
                return openPredictions.deployed();
            }).then(open => {
                openPredictionsInstance = open;
                return feedMasterInstance.pushNewFeed(10, 6, "BTCUSD", "bitcoin dollar exchange rate", { from: accounts[0], value: 100 });
            })
            .then(() => {
                return feedMasterInstance.getIDsForFeed.call("BTCUSD");
            }).then((result) => {
                BTCUSDID = result;
                console.log(`BTCUSD: ${BTCUSDID}`);
                return openPredictionsInstance.setFeedMaster(feedMasterInstance.address);

            }).then(() => console.log("before: setup complete"));
    });

    test("run before", async () => {
        console.log(accounts[1]);
    });


    //FIX: invalid number of arguments to solidity function: fails for both truffle and ganache
    test("place Prediction at valid feed", async () => {
        await openPredictionsInstance.placePrediction(BTCUSDID, 1300, { from: accounts[2] });
    });

    // test("get prediction for valid feed", async () => {
    //     var predictions = await openPredictionsInstance.getPredictionsByFeedIdSinceBlock.call(0, 0);
    //     console.log(JSON.stringify(predictions));

    // });

});