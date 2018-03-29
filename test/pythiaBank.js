let BigNumber = require('bignumber.js');
let scaleBackBigNumber = (number, factor) => parseInt(number.dividedBy(factor).toString());
let pythiaBank = artifacts.require("PythiaBank");
let async = require("./helpers/async.js");
let test = async.test;
let beforeTest = require("./helpers/async.js").beforeTest;
let expectThrow = require("./helpers/expectThrow.js").handle;
let getBalance = async.getBalancePromise;

contract('PythiaBank', accounts => {
    var pythiaBankInstance;
    before((done) => {
        pythiaBank.deployed()
            .then(instance => {
                pythiaBankInstance = instance;
                done();
            })
            .catch(error => done(error));
    });

    assertCurrentValue = (value, amount, account, message = "") => {
        assert.equal(parseInt(value[0]), amount, "amount incorrect, " + message);
        assert.equal(value[1], account, "address incorrect, " + message);
    }
});