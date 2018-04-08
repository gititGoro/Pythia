let BigNumber = require('bignumber.js');
let scaleBackBigNumber = (number, factor) => parseInt(number.dividedBy(factor).toString());
let pythiaBank = artifacts.require("PythiaBank");
let accessController = artifacts.require("AccessController");
let scarcity = artifacts.require("Scarcity");
let scarcityStore = artifacts.require("ScarcityStore");
let async = require("./helpers/async.js");
let test = async.test;
let expectThrow = require("./helpers/expectThrow.js").handle;
let getBalance = async.getBalancePromise;

contract('PythiaBank', accounts => {
    var pythiaBankInstance, accessControllerInstance, scarcityInstance;

    let initializer = async () => {
        accessControllerInstance = await accessController.deployed();
        pythiaBankInstance = await pythiaBank.deployed();

        scarcityInstace = await scarcityInstance.deployed();
    }

    before((done) => {
        initializer()
            .then(done)
            .catch(error => done(error));
    });

    test("send ether triggers callback function that stores deposit", async () => {

    });

    test("sending scarcity with notify call stores deposit", async () => {

    });

    assertCurrentValue = (value, amount, account, message = "") => {
        assert.equal(parseInt(value[0]), amount, "amount incorrect, " + message);
        assert.equal(value[1], account, "address incorrect, " + message);
    }
});