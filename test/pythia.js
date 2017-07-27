var Pythia = artifacts.require("../contracts/Pythia.sol");

contract('Pythia', function (accounts) {
    var PythiaInstance;
    var ethzarProphecyLength;

    it("should submit 1 integer prophecy to ETHZAR", () => {
        return Pythia.deployed().then(instance => {
            PythiaInstance = instance;
        });
        var eventResult;
        var eventFired = false;
        instance.watch((error, response) => {
            eventResult = response;
            assert.equal(eventResult, "horse");
            eventFired=true;
        });

        instance.SubmitIntegerProphecy("ETHZAR", 120);
        while(!eventFired);
        
    });
});