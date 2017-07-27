var AccessRestriction = artifacts.require("../contracts/AccessRestriction.sol");
var Pythia = artifacts.require("../contracts/Pythia.sol");

module.exports = function(deployer) {
  deployer.deploy(AccessRestriction);
  deployer.link(AccessRestriction, Pythia);
  deployer.deploy(Pythia);
};
