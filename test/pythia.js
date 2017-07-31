var Pythia = artifacts.require("../contracts/Pythia.sol");

contract('Pythia', function (accounts) {
    var PythiaInstance;
    var ethzarProphecyLength;
    var firstAccount = accounts[0];
    var secondAccount = accounts[1];
    var submitResult;

    var fixtureBounty = {
                maxBlockRange: 10,
                weiRewardPerOracle: 100,
                RequiredSampleSize: 4,
                maxValueRange: 13,
                decimalPlaces:2
            };

    before(() => {
        return Pythia.deployed().then(instance => {
            PythiaInstance = instance;

            return instance.PostBounty("ETHZAR", bounty.maxBlockRange,
                bounty.maxValueRange, bounty.RequiredSampleSize, bounty.decimalPlaces, { from: secondAccount, value:"10000000" });
        })
            .then(result => submitResult = result);
    });

});