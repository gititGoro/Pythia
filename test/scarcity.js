let BigNumber = require('bignumber.js');
let scaleBackBigNumber = (number, factor) => parseInt(number.dividedBy(factor).toString());
let scarcity = artifacts.require("Scarcity");
let async = require("./helpers/async.js");
let test = async.test;
let beforeTest = require("./helpers/async.js").beforeTest;
let expectThrow = require("./helpers/expectThrow.js").handle;
let getBalance = async.getBalancePromise;

contract('Scarcity', accounts => {
    var scarcityInstance;
    before((done) => {
        scarcity.deployed()
            .then(instance => {
                scarcityInstance = instance;
                done();
            })
            .catch(error => done(error));
    });

    test ("send tokens to 2 users and let them send to each other", async ()=> {
        let supply = await scarcityInstance.totalSupply.call().toString();
        assert.equal(supply,"100000000000000000000000000");
    });

    /*
    test("place Prediction at valid feed", async () => {
        let weiDeposit = new BigNumber("1.0e+22");
        let guessingOracleInitialBalance = await getBalance(accounts[2]);
        let predictionIndex = await openPredictionsInstance.getNextIndexForFeed.call(BTCUSDID);
        await (openPredictionsInstance.placePrediction(BTCUSDID, 1300, { from: accounts[2], value: weiDeposit.toString() }));

        let scaledAfterBalance = scaleBackBigNumber(await getBalance(accounts[2]), weiDeposit);
        let scaledBackBefore = scaleBackBigNumber(guessingOracleInitialBalance, weiDeposit);

        assert.isAbove(scaledBackBefore, scaledAfterBalance);

        predictionIndex = parseInt(await openPredictionsInstance.getNextIndexForFeed.call(BTCUSDID)) - 1;
        assert.equal(predictionIndex, 0, "there should be one predictions for btcusd");

        let guessingOracle = await openPredictionsInstance.getPredictionOracleForFeedIdAtIndex.call(BTCUSDID, predictionIndex);
        assert.equal(guessingOracle, accounts[2], "guessing oracle should by account[2]");

        let predictionValue = await openPredictionsInstance.getPredictionValueForFeedIdAtIndex.call(BTCUSDID, predictionIndex);
        assert.equal(predictionValue, 1300, "predicted valued should be 1300");

        let depositForOracle = await openPredictionsInstance.getDepositForOracle.call(guessingOracle);
        assert.equal(depositForOracle.toString(), weiDeposit.toString(), `deposit for oracle should equal ${weiDeposit.toString()} wei.`);

        await openPredictionsInstance.withdraw(weiDeposit.dividedBy(4).toString(), { from: accounts[2] });

        let depositForOracleAfterWithdrawal = await openPredictionsInstance.getDepositForOracle.call(guessingOracle);
        assert.equal(depositForOracleAfterWithdrawal, weiDeposit.dividedBy(4).multipliedBy(3).toString(), "deposit for oracle should equal 10");
    });


    test("place many valid predictions so that circular buffer wraps around", async () => {
        let index = parseInt(await openPredictionsInstance.getNextIndexForFeed.call(BTCUSDID));
             await openPredictionsInstance.resetPredictionIterator(BTCUSDID, accounts[0]);

        for (let i = index + 1; i <= 25; i++) {
            await (openPredictionsInstance.placePrediction(BTCUSDID, 1300 * i, { from: accounts[(i) % accounts.length], value: 100 }));
            index = parseInt(await openPredictionsInstance.getNextIndexForFeed.call(BTCUSDID));
            assert.equal(index, i % 20, "expected index to wrap around");
            await openPredictionsInstance.movePredictionIterator(BTCUSDID, accounts[0]);
            let currentValue = await openPredictionsInstance.getCurrentPredictionValue(BTCUSDID, accounts[0]);
            assertCurrentValue(currentValue, 1300 * i, accounts[index % accounts.length], "i: " + i);
        }
    });

    test("place Prediction at invalid feed", async () => {
        expectThrow(openPredictionsInstance.placePrediction(10, 1300, { from: accounts[2], value: 100 }));
    });

    test("place Prediction at valid feed with too small a deposit", async () => {
        expectThrow(openPredictionsInstance.placePrediction(BTCUSDID, 1300, { from: accounts[2], value: 99 }));
    });
  */
    assertCurrentValue = (value, amount, account, message = "") => {
        assert.equal(parseInt(value[0]), amount, "amount incorrect, " + message);
        assert.equal(value[1], account, "address incorrect, " + message);
    }
});