let circularBuffer = artifacts.require("CircularBufferLib");
let safeMath = artifacts.require("SafeMath");
let pythiaBank = artifacts.require("PythiaBank");
let scarcityStore = artifacts.require("ScarcityStore");
let accessController = artifacts.require("AccessController");


module.exports = function(deployer) {
    deployer.deploy(circularBuffer);
    deployer.deploy(safeMath);
    deployer.deploy(accessController);
    deployer.link(safeMath, [scarcityStore, pythiaBank]);
  }
  