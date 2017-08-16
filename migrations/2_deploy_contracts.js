var AccessRestriction = artifacts.require("../contracts/AccessRestriction.sol");
var Pythia = artifacts.require("../contracts/Pythia.sol");
var StringUtils = artifacts.require("../contracts/StringUtils.sol");
var PythiaBase = artifacts.require("../contracts/PythiaBase.sol");

module.exports = function(deployer) {
  deployer.deploy(AccessRestriction);
  deployer.deploy(StringUtils);
  deployer.deploy(PythiaBase);
  deployer.link(AccessRestriction, PythiaBase);
  deployer.link(PythiaBase, Pythia);
  deployer.link(StringUtils, Pythia);
  deployer.deploy(Pythia, {gas: 6000000});
};
