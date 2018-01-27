var FeedMaster = artifacts.require("FeedMaster");
var Judge = artifacts.require("Judge");
var OpenPredictions = artifacts.require("OpenPredictions");
var KreshmoiHistory = artifacts.require("KreshmoiHistory");

module.exports = function (callback) {
    var feedMasterInstance;
    var judgeInstance;
    var kreshmoiInstance;
    var feed = FeedMaster.deployed()
        .then(instance => {
            feedMasterInstance = instance;
            return Judge.deployed();
        }).then(instance => {
            judgeInstance = instance;
            return KreshmoiHistory.deployed();
        })
        .then(instance => {
            kreshmoiInstance = instance;
            return OpenPredictions.deployed();
        })
        .then(openInstance => {
            if (web3 != null) {

                web3.eth.getAccounts(function (error, accounts) {

                    return openInstance.setDependencies(judgeInstance.address, feedMasterInstance.address, 10000, { from: accounts[0] })
                        .then(() => {
                            return judgeInstance.setDependencies(feedMasterInstance.address, openInstance.address, kreshmoiInstance.address, { from: accounts[0] });
                        })
                        .then(() => {
                            return kreshmoiInstance.setDependencies(judgeInstance.address, feedMasterInstance.address, { from: accounts[0] });
                        })
                        .then(() => {
                            console.log("finished injections.js");
                            return callback();
                        })
                        .catch(error => callback(error));
                });
            }
            else
                throw "web 3 does not exist";
            return true;

        })
        .then(() => callback())
        .catch(error => callback(error));
}