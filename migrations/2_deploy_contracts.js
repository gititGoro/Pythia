var AccessRestriction = artifacts.require("../contracts/AccessRestriction.sol");
var Pythia = artifacts.require("../contracts/Pythia.sol");
var StringUtils = artifacts.require("../contracts/StringUtils.sol");

module.exports = function(deployer) {
  deployer.deploy(AccessRestriction);
  deployer.deploy(StringUtils);
  deployer.link(AccessRestriction, Pythia);
  deployer.link(StringUtils, Pythia);
  deployer.deploy(Pythia);
};
