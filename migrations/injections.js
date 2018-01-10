var FeedMaster = artifacts.require("../contracts/FeedMaster.sol");
var OpenPredictions = artifacts.require("../contracts/OpenPredictions.sol");

module.exports = function (callback) {
    var feedMasterInstance;
    var feed = FeedMaster.deployed()
        .then(instance => {
            feedMasterInstance = instance;
            return OpenPredictions.deployed();
        })
        .then(openInstance => {
            if (web3 != null) {

                web3.eth.getAccounts(function (error, accounts) {

                    return openInstance.setFeedMaster(feedMasterInstance.address, { from: accounts[0],gas:"60000"})
                        .then(() => callback())
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