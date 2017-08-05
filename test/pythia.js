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
        var accountBalances = [0,0,0,0];
        var gasForOfferKreshmoi = "16777215";
        var gasForCollectReward = "1000000";
        var fixtureBounty = {
            maxBlockRange: 1000,
            szaboRewardPerOracle: 10000000,
            RequiredSampleSize: 4,
            maxValueRange: 13,
            decimalPlaces: 2
        };

        before(() => {
            return Pythia.deployed().then(instance => {
                PythiaInstance = instance;
            });
        });

        it("Checking balances and then post bounty", () => {
            return getBalancePromise(secondAccount)
                .then(initialBalance => {
                    console.log("GetBountyReward successfully called");
                    accountBalances[0] = convertToEther(initialBalance);
                    return getBalancePromise(thirdAccount);
                }).then(initialBalance => {
                    accountBalances[1] = convertToEther(initialBalance);
                    return getBalancePromise(fourthAccount);
                }).then(initialBalance => {
                    accountBalances[2] = convertToEther(initialBalance);
                     return getBalancePromise(fifthAccount);
                }).then(initialBalance => {
                    accountBalances[3] = convertToEther(initialBalance);
                    return PythiaInstance.PostBounty("ETHZAR", fixtureBounty.maxBlockRange,
                        fixtureBounty.maxValueRange, fixtureBounty.RequiredSampleSize, fixtureBounty.decimalPlaces,
                        { from: secondAccount, value: "40000000000000000000" });
                });

        });

        it("respond to bounty and assert", () => { //FAILING
            console.log("about to offer kreshmoi");
            return PythiaInstance.OfferKreshmoi("ETHZAR", 2, { from: secondAccount, gas: gasForOfferKreshmoi })
                .then(result => {
                    console.log("assert of first offer");
                    assert.equal(result.logs.length, 2, "expected logs emitted");

                    assertEventLog(result.logs[0], "BountyCleared", "ETHZAR", 0, "Max block range exceeded. All previous bounty hunters have been erased. Bounty reset at current block.");
                    assertEventLog(result.logs[1], "KreshmoiOffered", secondAccount, "ETHZAR");
                    return PythiaInstance.GetKreshmoi.call("ETHZAR");
                })
                .then(kreshmoi => {
                    console.log("assert of kreshmoi after first offer");
                    assert.equal(kreshmoi[0].length, 0, "Expected zero successful kreshmoi");
                    return PythiaInstance.OfferKreshmoi("ETHZAR", 10, { from: thirdAccount, gas: gasForOfferKreshmoi});
                }).then(result => {
                    console.log("assert of second offer");
                    assert.equal(result.logs.length, 1, "expected logs emitted");
                    assertEventLog(result.logs[0], "KreshmoiOffered", thirdAccount, "ETHZAR");
                    return PythiaInstance.GetKreshmoi.call("ETHZAR");
                }).then(kreshmoi => {
                    console.log("assert of kreshmoi after second offer");
                    assert.equal(kreshmoi[0].length, 0, "Expected zero successful kreshmoi");
                    console.log("fourthAccount: " + fourthAccount);
                    return PythiaInstance.OfferKreshmoi("ETHZAR", 4, { from: fourthAccount, gas: gasForOfferKreshmoi });
                }).then(result => {
                    console.log("assert of third offer");
                    assert.equal(result.logs.length, 1, "expected logs emitted");
                    assertEventLog(result.logs[0], "KreshmoiOffered", fourthAccount, "ETHZAR");
                    return PythiaInstance.GetKreshmoi.call("ETHZAR");
                }).then(kreshmoi => {
                    console.log("assert of kreshmoi third second offer");
                    assert.equal(kreshmoi[0].length, 0, "Expected zero successful kreshmoi");
                    return PythiaInstance.OfferKreshmoi("ETHZAR", 7, { from: fifthAccount, gas: gasForOfferKreshmoi });
                }).then(result => {
                    console.log("assert of final offer");
                    assert.equal(result.logs.length, 2, "expected logs emitted");
                    assertEventLog(result.logs[0], "KreshmoiOffered", fifthAccount, "ETHZAR");
                    assertEventLog(result.logs[1], "ProphecyDelivered", "ETHZAR");
                    return PythiaInstance.GetKreshmoi.call("ETHZAR");
                }).then(kreshmoi => {
                    console.log("expecting a kreshmoi");
                    assert.equal(kreshmoi[0].length, 1, "Expected a successful kreshmoi");

                    assert.equal(kreshmoi[0][0].toNumber(), 525);
                    assert.equal(kreshmoi[1][0].toNumber(), 2);
                    return PythiaInstance.GetBountyReward.call({ from: secondAccount });

                    //assert second account was paid
                }).then(reward => {
                    console.log("Beggining to assert collection");
                    var etherReward = convertToEther(reward);
                    assert.equal(etherReward, 10);
                    return PythiaInstance.CollectBountyReward({ from: secondAccount, gas: gasForCollectReward });
                }).then(result => {
                    return getBalancePromise(secondAccount);
                }).then(balance => {
                    console.log("assert first balance");

                    assert.equal(accountBalances[0], convertToEther(balance));
                    return PythiaInstance.GetBountyReward.call({ from: thirdAccount });
                })
                //assert third account was paid    
                .then(reward => {
                    assert.equal(reward.toNumber(), 100);
                    return PythiaInstance.CollectBountyReward({ from: seconthirdAccountdAccount, gas: gasForCollectReward });
                }).then(result => {
                    return getBalancePromise(thirdAccount);
                }).then(balance => {
                    assert.equal(accountBalances[1] + 100, balance.toNumber());
                    return PythiaInstance.GetBountyReward.call({ from: fourthAccount });
                })
                //assert fourth account was paid
                .then(reward => {
                    assert.equal(reward.toNumber(), 100);
                    return PythiaInstance.CollectBountyReward({ from: fourthAccount, gas: gasForCollectReward });
                }).then(result => {
                    return getBalancePromise(fourthAccount);
                }).then(balance => {
                    assert.equal(accountBalances[2] + 100, balance.toNumber());
                    return PythiaInstance.GetBountyReward.call({ from: fifthAccount });
                })
                //assert fifth account was paid
                .then(reward => {
                    assert.equal(reward.toNumber(), 100);
                    return PythiaInstance.CollectBountyReward({ from: fifthAccount, gas: gasForCollectReward });
                }).then(result => {
                    return getBalancePromise(fifthAccount);
                }).then(balance => {
                    assert.equal(accountBalances[3] + 100, balance.toNumber());
                    return done();
                });
        });

    });

    function convertToEther(bigNumber){
        return bigNumber.dividedBy("1000000000000000000").toNumber();
    }

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