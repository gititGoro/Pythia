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
        var accountBalances = [0, 0, 0, 0];
        var gasForofferKreshmoi = 6000000;
        var gasForCollectReward = "1000000";
        var gasForPostBounty = "6000000";
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
            }).then(() => {
                return getBalancePromise(secondAccount);
            }).then(initialBalance => {
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
            });
        });

        it("validates bounty, claims refund and then posts", () => {
            //(string datafeed,uint8 requiredSampleSize,uint16 maxBlockRange,uint maxValueRange,uint8 decimalPlaces) payable{
            return PythiaInstance.generatePostBountyValidationTicket("ETHZAR", fixtureBounty.RequiredSampleSize,
                fixtureBounty.maxBlockRange, fixtureBounty.maxValueRange,
                fixtureBounty.decimalPlaces,
                { from: firstAccount, value: "40000000000000000000", gas: gasForPostBounty })
                .then(result => {
                    return PythiaInstance.claimRefundsDue({ from: firstAccount });
                })
                .then(result => {
                    return PythiaInstance.postBounty({ from: firstAccount, value: "40000000000000000000", gas: gasForPostBounty });
                });
        });

        it("respond to bounty and assert", () => {

            return PythiaInstance.offerKreshmoi("ETHZAR", 0, 2, { from: secondAccount, gas: gasForofferKreshmoi })
                .then(result => {
                    console.log("asserting offer kreshmoi");
                    assert.equal(result.logs.length, 2, "expected logs emitted");

                    assertEventLog(result.logs[0], "BountyCleared", "ETHZAR", 0, "Max block range exceeded. All previous bounty hunters have been erased. Bounty reset at current block.");
                    assertEventLog(result.logs[1], "KreshmoiOffered", secondAccount, "ETHZAR");
                    return PythiaInstance.getKreshmoi.call("ETHZAR");
                })
                .then(kreshmoi => {
                    assert.equal(kreshmoi[0].length, 0, "Expected zero successful kreshmoi");
                    return PythiaInstance.offerKreshmoi("ETHZAR", 0, 10, { from: thirdAccount, gas: gasForofferKreshmoi });
                }).then(result => {
                    assert.equal(result.logs.length, 1, "expected logs emitted");
                    assertEventLog(result.logs[0], "KreshmoiOffered", thirdAccount, "ETHZAR");
                    return PythiaInstance.getKreshmoi.call("ETHZAR");
                }).then(kreshmoi => {
                    assert.equal(kreshmoi[0].length, 0, "Expected zero successful kreshmoi");
                    return PythiaInstance.offerKreshmoi("ETHZAR", 0, 4, { from: fourthAccount, gas: gasForofferKreshmoi });
                }).then(result => {
                    assert.equal(result.logs.length, 1, "expected logs emitted");
                    assertEventLog(result.logs[0], "KreshmoiOffered", fourthAccount, "ETHZAR");
                    return PythiaInstance.getKreshmoi.call("ETHZAR");
                }).then(kreshmoi => {
                    assert.equal(kreshmoi[0].length, 0, "Expected zero successful kreshmoi");
                    return PythiaInstance.offerKreshmoi("ETHZAR", 0, 7, { from: fifthAccount, gas: gasForofferKreshmoi });
                }).then(result => {
                    assert.equal(result.logs.length, 2, "expected logs emitted");
                    assertEventLog(result.logs[0], "KreshmoiOffered", fifthAccount, "ETHZAR");
                    assertEventLog(result.logs[1], "ProphecyDelivered", "ETHZAR");
                    return PythiaInstance.getKreshmoi.call("ETHZAR");
                }).then(kreshmoi => {
                    assert.equal(kreshmoi[0].length, 1, "Expected a successful kreshmoi");
                    assert.equal(kreshmoi[0][0].toNumber(), 525);
                    assert.equal(kreshmoi[1][0].toNumber(), 2);
                    return PythiaInstance.getBountyReward.call({ from: secondAccount });

                    //assert second account was paid
                }).then(reward => {
                    var etherReward = convertToEther(reward);
                    assert.equal(etherReward, 10);
                    return PythiaInstance.collectBountyReward({ from: secondAccount, gas: gasForCollectReward });
                }).then(result => {
                    return getBalancePromise(secondAccount);
                }).then(balance => {
                    assert.isAtLeast(convertToEther(balance), accountBalances[0] + 9);//9 because some gas
                    return PythiaInstance.getBountyReward.call({ from: thirdAccount });
                })
                //assert third account was paid    
                .then(reward => {
                    var etherReward = convertToEther(reward);
                    assert.equal(etherReward, 10);
                    return PythiaInstance.collectBountyReward({ from: thirdAccount, gas: gasForCollectReward });
                }).then(result => {
                    return getBalancePromise(thirdAccount);
                }).then(balance => {
                    assert.isAtLeast(convertToEther(balance), accountBalances[1] + 9);
                    return PythiaInstance.getBountyReward.call({ from: fourthAccount });
                })
                //assert fourth account was paid
                .then(reward => {
                    var etherReward = convertToEther(reward);
                    assert.equal(etherReward, 10);
                    return PythiaInstance.collectBountyReward({ from: fourthAccount, gas: gasForCollectReward });
                }).then(result => {
                    return getBalancePromise(fourthAccount);
                }).then(balance => {
                    assert.isAtLeast(convertToEther(balance), accountBalances[2] + 9);
                    return PythiaInstance.getBountyReward.call({ from: fifthAccount });
                })
                //assert fifth account was paid
                .then(reward => {
                    var etherReward = convertToEther(reward);
                    assert.equal(etherReward, 10);
                    return PythiaInstance.collectBountyReward({ from: fifthAccount, gas: gasForCollectReward });
                }).then(result => {
                    return getBalancePromise(fifthAccount);
                }).then(balance => {
                    assert.isAtLeast(convertToEther(balance), accountBalances[3] + 9);
                });
        });

    });

    function convertToEther(bigNumber) {
        console.log("Converting big number " + bigNumber.toString());
        return bigNumber.dividedBy("1000000000000000000").toNumber();

    }

    function getBalancePromise(account, timeout) {
        timeout == null ? 1 : timeout;
        return new Promise(function (resolve, error) {
            setTimeout(() => {
                return web3.eth.getBalance(account, function (err, hashValue) {

                    if (err)
                        return error(err);
                    else {
                        return resolve(hashValue);
                    }
                });
            }, timeout);
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