var Pythia = artifacts.require("../contracts/Pythia.sol");

contract('Pythia', function (accounts) {
    var PythiaInstance;
    var ethzarProphecyLength;
    var fistAccount = accounts[0];
    var secondAccount = accounts[1];


    it("should submit 1 integer prophecy to ETHZAR", () => {
        return Pythia.deployed().then(instance => {
            PythiaInstance = instance;
            return instance.SubmitIntegerProphecy("ETHZAR", 120, { from: secondAccount });
        }).then(result => {
            var logs = result.logs;
            assert.equal(logs.length, 1, "There should only be one event log");

        });
    });
});