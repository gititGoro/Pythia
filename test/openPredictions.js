let openPredictions = artifacts.require("../contracts/OpenPredictions.sol");
let feedMaster = artifacts.require("../contracts/FeedMaster.sol");
let async = require("./helpers/async.js");
let test = async.test;
let beforeTest = require("./helpers/async.js").beforeTest;
let expectThrow = require("./helpers/expectThrow.js").handle;
let getBalance = async.getBalancePromise;

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

            }).then(() => { console.log("before: setup complete"); done(); })
            .catch(error => done(error));
    });

    test("place Prediction at valid feed", async () => {
        let guessingOracleInitialBalance = await getBalance(accounts[2]);
        let predictionIndex = await openPredictionsInstance.getLastIndexForFeed.call(BTCUSDID);
        assert.equal(predictionIndex, 1000000, "there should be no predictions for btcusd yet, represented by 1 million");
        await (openPredictionsInstance.placePrediction(BTCUSDID, 1300, { from: accounts[2], value: 100 }));

        let guessingOracleBalanceAfter = await getBalance(accounts[2]);
        assert.isAbove(guessingOracleInitialBalance, guessingOracleBalanceAfter + 100);

        predictionIndex = await openPredictionsInstance.getLastIndexForFeed.call(BTCUSDID);
        assert.equal(predictionIndex, 0, "there should be one predictions for btcusd");

        let guessingOracle = await openPredictionsInstance.getPredictionOracleForFeedIdAtIndex.call(BTCUSDID, predictionIndex);
        assert.equal(guessingOracle, accounts[2], "guessing oracle should by account[2]");

        let predictionValue = await openPredictionsInstance.getPredictionValueForFeedIdAtIndex.call(BTCUSDID, predictionIndex);
        assert.equal(predictionValue, 1300, "predicted valued should be 1300");

        let depositForOracle = await openPredictionsInstance.getDepositForOracle.call(guessingOracle);
        assert.equal(depositForOracle, 100, "deposit for oracle should equal 100");

        await openPredictionsInstance.withdraw(90, { from: accounts[2] });

        let depositForOracleAfterWithdrawal = await openPredictionsInstance.getDepositForOracle.call(guessingOracle);
        assert.equal(depositForOracleAfterWithdrawal, 10, "deposit for oracle should equal 10");
    });

    test("place Prediction at invalid feed", async () => {
        expectThrow(openPredictionsInstance.placePrediction(10, 1300, { from: accounts[2], value: 100 }));
    });

    test("place Prediction at valid feed with too small a deposit", async () => {
        expectThrow(openPredictionsInstance.placePrediction(BTCUSDID, 1300, { from: accounts[2], value: 99 }));
    });

});