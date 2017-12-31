var AccessRestriction = artifacts.require("../contracts/AccessRestriction.sol");
var Pythia = artifacts.require("../contracts/Pythia.sol");
var PythiaBase = artifacts.require("../contracts/PythiaBase.sol");
var FeedMaster = artifacts.require("../contracts/FeedMaster.sol");
var OpenPredictions = artifacts.require("../contracts/OpenPredictions.sol");

module.exports = function (deployer) {
  deployer.deploy(AccessRestriction);
  deployer.deploy(PythiaBase);
  deployer.link(AccessRestriction, PythiaBase);
  deployer.link(AccessRestriction, FeedMaster);
  deployer.link(PythiaBase, Pythia);
  deployer.deploy(Pythia, { gas: 6000000 });
  deployer.deploy(FeedMaster, { gas: 6000000 });
  deployer.deploy(OpenPredictions, { gas: 6000000 });
};
