let pythiaBank = artifacts.require("PythiaBank");
let scarcityStore = artifacts.require("ScarcityStore");

module.exports = function(deployer) {
    deployer.deploy(scarcityStore);
    deployer.deploy(pythiaBank);
  }
  