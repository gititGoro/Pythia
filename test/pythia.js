var Pythia = artifacts.require("../contracts/Pythia.sol");

contract('Pythia', function (accounts) {
    var PythiaInstance;
    var ethzarProphecyLength;
    var fistAccount = accounts[0];
    var secondAccount = accounts[1];
    var submitResult;

    before(() => {
        return Pythia.deployed().then(instance => {
            PythiaInstance = instance;
            return instance.SubmitIntegerProphecy("ETHZAR", 120, { from: secondAccount });
        })
        .then(result => submitResult = result);
    });

    it("should submit 1 integer prophecy to ETHZAR", () => {
        var logs = submitResult.logs;
        assert.equal(logs.length, 1, "There should only be one event log");
        var log = logs[0];

        assert.equal(log.event, "ProphecySubmission");
        assert.isTrue(log.args != null);
        assert.equal(Object.keys(log.args).length, 2, "args length should equal 2");

        assert.equal(log.args.from, secondAccount);
        assert.equal(log.args.datafeed, "ETHZAR");
    });
});