let openPredictions = artifacts.require("OpenPredictions");
let feedMaster = artifacts.require("FeedMaster");
let kreshmoiHistory = artifacts.require("KreshmoiHistory");
let judge = artifacts.require("Judge");
let async = require("./helpers/async.js");
let test = async.test;
let beforeTest = require("./helpers/async.js").beforeTest;
let expectThrow = require("./helpers/expectThrow.js").handle;
let getBalance = async.getBalancePromise;

contract('OpenPredictions', accounts => {
    var feedMasterInstance, openPredictionsInstance, judgeInstance, kreshmoiHistoryInstance, BTCUSDID;
    before((done) => {
        feedMaster.deployed()
            .then(instance => {
                feedMasterInstance = instance;
                return openPredictions.deployed();
            }).then(open => {
                openPredictionsInstance = open;
                return feedMasterInstance.pushNewFeed(10, 6, 100, "BTCUSD", "bitcoin dollar exchange rate", { from: accounts[0], value: 100 });
            }).then(() => {
                return judge.deployed();
            })
            .then(instance => {
                judgeInstance = instance;
                return kreshmoiHistory.deployed();
            })
            .then(instance => {
                kreshmoiHistoryInstance = instance;
                return feedMasterInstance.getIDsForFeed.call("BTCUSD");
            }).then(result => {
                BTCUSDID = parseInt(result[0]);
                return openPredictionsInstance.setDependencies(judgeInstance.address, feedMasterInstance.address, 10);

            }).then(() => {
                done();
                // return kreshmoiHistoryInstance.setDependencies(judgeInstance.address, feedMasterInstance.address);
            })/*.then(() => {
                return judgeInstance.setDependencies(feedMasterInstance.address, openPredictionsInstance.address, kreshmoiHistoryInstance.address);
            })
            .then(() => { console.log("before: setup complete"); done(); })*/
            .catch(error => done(error));
    });

    test("place Prediction at valid feed", async () => {
        let guessingOracleInitialBalance = await getBalance(accounts[2]);
        let predictionIndex = await openPredictionsInstance.getLastIndexForFeed.call(BTCUSDID);
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

    test("place many valid predictions so that circular buffer wraps around", async () => {
        assert.equal(0, 1, "test not implemented yet");
    });

    test ("judge contract burns deposits", async () => {
        assert.equal(0, 1, "test not implemented yet");
    });

    test ("non judge address burns deposits and fails", async () => {
        assert.equal(0, 1, "test not implemented yet");
    });

    test("place Prediction at invalid feed", async () => {
        expectThrow(openPredictionsInstance.placePrediction(10, 1300, { from: accounts[2], value: 100 }));
    });

    test("place Prediction at valid feed with too small a deposit", async () => {
        expectThrow(openPredictionsInstance.placePrediction(BTCUSDID, 1300, { from: accounts[2], value: 99 }));
    });

});