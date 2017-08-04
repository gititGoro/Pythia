//TO TEST: accounts are unique, moving blockrange window, large range spoils a bounty,mismatch between sending value and reward, rolling bounty window
//TO TEST: Description stuff
//Todo: refactor test into subtests
var Pythia = artifacts.require("../contracts/Pythia.sol");

contract('Pythia', function (accounts) {

    describe("should accept 4 successful kreshmoi and only reward at the end", () => {

        var PythiaInstance;
        var firstAccount = accounts[0];
        var secondAccount = accounts[1];
        var thirdAccount = accounts[2];
        var fourthAccount = accounts[3];
        var fifthAccount = accounts[4];

        var fixtureBounty = {
            maxBlockRange: 10,
            weiRewardPerOracle: 100,
            RequiredSampleSize: 4,
            maxValueRange: 13,
            decimalPlaces: 2
        };

        before(() => {
            return Pythia.deployed().then(instance => {
                PythiaInstance = instance;
            });
        });

        it("should offer 4 successful kreshmoi", () => {

            var accountBalances = [0, 0, 0, 0];
            return PythiaInstance.GetBountyReward.call({ from: secondAccount })
                .then(initialBalance => {
                    console.log("GetBountyReward successfully called");
                    accountBalances[0] = initialBalance.toNumber();
                    return PythiaInstance.GetBountyReward.call({ from: thirdAccount });
                }).then(initialBalance => {
                    accountBalances[1] = initialBalance.toNumber();
                    return PythiaInstance.GetBountyReward.call({ from: fourthAccount });
                }).then(initialBalance => {
                    accountBalances[2] = initialBalance.toNumber();
                    return PythiaInstance.GetBountyReward.call({ from: fifthAccount });
                }).then(initialBalance => {
                    accountBalances[3] = initialBalance.toNumber();
                    return PythiaInstance.PostBounty("ETHZAR", fixtureBounty.maxBlockRange,
                        fixtureBounty.maxValueRange, fixtureBounty.RequiredSampleSize, fixtureBounty.decimalPlaces,
                        { from: secondAccount, value: "400" });
                }).then(result => {
                    console.log("about to offer kreshmoi");
                    return PythiaInstance.OfferKreshmoi("ETHZAR", 2, { from: secondAccount });
                })
                .then(result => {
                    assert.equal(result.logs.length, 2, "expected 2 logs emitted");

                    assertEventLog(result.logs[0], "BountyCleared", "ETHZAR", 0, "Max block range exceeded. All previous bounty hunters have been erased. Bounty reset at current block.");
                    assertEventLog(result.logs[1], "KreshmoiOffered", secondAccount, "ETHZAR");
                    return PythiaInstance.GetKreshmoi.call("ETHZAR");
                })
                .then(kreshmoi => {
                    assert.equal(kreshmoi.length, 0, "Expected zero successful kreshmoi");
                    return PythiaInstance.OfferKreshmoi("ETHZAR", 10, { from: thirdAccount });
                }).then(result => {
                    
                    assert.equal(result.logs.length, 1, "expected 2 logs emitted");
                    assertEventLog(result.logs[0], "KreshmoiOffered", thirdAccount, "ETHZAR");
                    return PythiaInstance.GetKreshmoi.call("ETHZAR");
                }).then(kreshmoi => {
                    assert.equal(kreshmoi.length, 0, "Expected zero successful kreshmoi");
                    return PythiaInstance.OfferKreshmoi("ETHZAR", 4, { from: fourthAccount });
                }).then(result => {
       
                     assert.equal(result.logs.length, 1, "expected 2 logs emitted");
                    assertEventLog(result.logs[0], "KreshmoiOffered", fourthAccount, "ETHZAR");
                    return PythiaInstance.GetKreshmoi.call("ETHZAR");
                }).then(kreshmoi => {
                    assert.equal(kreshmoi.length, 0, "Expected zero successful kreshmoi");
                    return PythiaInstance.OfferKreshmoi("ETHZAR", 7, { from: fifthAccount });
                }).then(result => {
                    assert.equal(result.logs.length, 1, "expected 2 logs emitted");
                    assertEventLog(result.logs[0], "KreshmoiOffered", fifthAccount, "ETHZAR");
                    return PythiaInstance.GetKreshmoi.call("ETHZAR");
                }).then(kreshmoi => {
                    console.log("expecting a kreshmoi");
                    assert.equal(kreshmoi.length, 1, "Expected a successful kreshmoi");
                    assertKreshmoi(kreshmoi[0], 5.75);
                    return PythiaInstance.GetBountyReward.call({ from: secondAccount });

                    //assert second account was paid
                }).then(reward => {
                    assert.equal(reward.toNumber, 100);
                    return PythiaInstance.collectBountyReward({ from: secondAccount, gas: "21000000000" });
                }).then(result => {
                    return getBalancePromise(secondAccount);
                }).then(balance => {
                    assert.equal(initialBalance[0] + 100, balance.toNumber());
                    return PythiaInstance.GetBountyReward.call({ from: thirdAccount });
                })
                //assert third account was paid    
                .then(reward => {
                    assert.equal(reward.toNumber, 100);
                    return PythiaInstance.collectBountyReward({ from: seconthirdAccountdAccount, gas: "21000000000" });
                }).then(result => {
                    return getBalancePromise(thirdAccount);
                }).then(balance => {
                    assert.equal(initialBalance[1] + 100, balance.toNumber());
                    return PythiaInstance.GetBountyReward.call({ from: fourthAccount });
                })
                //assert fourth account was paid
                .then(reward => {
                    assert.equal(reward.toNumber, 100);
                    return PythiaInstance.collectBountyReward({ from: fourthAccount, gas: "21000000000" });
                }).then(result => {
                    return getBalancePromise(fourthAccount);
                }).then(balance => {
                    assert.equal(initialBalance[2] + 100, balance.toNumber());
                    return PythiaInstance.GetBountyReward.call({ from: fifthAccount });
                })
                //assert fifth account was paid
                .then(reward => {
                    assert.equal(reward.toNumber, 100);
                    return PythiaInstance.collectBountyReward({ from: fifthAccount, gas: "21000000000" });
                }).then(result => {
                    return getBalancePromise(fifthAccount);
                }).then(balance => {
                    assert.equal(initialBalance[3] + 100, balance.toNumber());
                    return done();
                });
        });
    });

    function getBalancePromise(account) {
        return new Promise(function (resolve, error) {

            return web3.eth.getBalance(account, function (err, hashValue) {

                if (err)
                    return error(err);
                else {
                    return resolve(hashValue);
                }
            });
        });
    }

    function assertKreshmoi(kreshmoi, decimalPlaces, value, sampleSize, valueRange, bountyPoster) {
        assert.equal(kreshmoi.decimalPlaces, decimalPlaces);
        assert.equal(kreshmoi.value, value);
        assert.equal(kreshmoi.sampleSize, sampleSize);
        assert.equal(kreshmoi.valueRange, valueRange);
        assert.equal(kreshmoi.bountyPoster, bountyPoster);
    }

    function assertEventLog(log, logType, ...expectedValues) {
        assert.equal(log.event, logType);
        assert.isTrue(log.args != null);
        var keys = Object.keys(log.args);
        assert.equal(keys.length, expectedValues.length, "args length should equal " + expectedValues.length);

        keys.forEach((key, index) => {
            assert.isTrue(keys.includes(key));
            assert.equal(log.args[key], expectedValues[index]);
        });
    }
});