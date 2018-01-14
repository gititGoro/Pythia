let openPredictions = artifacts.require("../contracts/OpenPredictions.sol");
let feedMaster = artifacts.require("../contracts/FeedMaster.sol");
let test = require("./helpers/async.js").test;
let beforeTest = require("./helpers/async.js").beforeTest;
let expectThrow = require("./helpers/expectThrow.js").handle;


contract('OpenPredictions', accounts => {
    var feedMasterInstance, openPredictionsInstance, BTCUSDID;
    before((done) => {
        feedMaster.deployed()
            .then(instance => {
                feedMasterInstance = instance;
                return openPredictions.deployed();
            }).then(open => {
                openPredictionsInstance = open;
                return feedMasterInstance.pushNewFeed(10, 6, 100, "BTCUSD", "bitcoin dollar exchange rate", { from: accounts[0], value: 100 });
            })
            .then(() => {
                return feedMasterInstance.getIDsForFeed.call("BTCUSD");
            }).then((result) => {
                BTCUSDID = parseInt(result[0]);
                return openPredictionsInstance.setFeedMaster(feedMasterInstance.address);

            }).then(() => {console.log("before: setup complete"); done();})
            .catch(error=>done(error));
    });

    test("run before", async () => {
        console.log(accounts[1]);
    });


   
    test("place Prediction at valid feed", async () => {
        var BTCUSDID_int = parseInt(BTCUSDID);
        await openPredictionsInstance.placePrediction(BTCUSDID, 1300, { from: accounts[2] });
    });

    // test("get prediction for valid feed", async () => {
    //     var predictions = await openPredictionsInstance.getPredictionsByFeedIdSinceBlock.call(0, 0);
    //     console.log(JSON.stringify(predictions));

    // });

});