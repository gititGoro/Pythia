var AccessRestriction = artifacts.require("AccessRestriction");
var AccessController = artifacts.require("baseContracts/AccessController");
var FeedMaster = artifacts.require("FeedMaster");
var CircularBuffer = artifacts.require("CircularBufferLib");
var SafeMath = artifacts.require("SafeMath");
var ScarcityStore = artifacts.require("ScarcityStore");
var Scarcity = artifacts.require("Scarcity");
var PythiaBank = artifacts.require("PythiaBank");

module.exports = function (deployer) {
  //deployer.deploy(AccessRestriction);
  // deployer.link(AccessRestriction,AccessController);
   deployer.deploy(AccessController);
  // deployer.deploy(CircularBuffer);
  // deployer.deploy(SafeMath);
  // deployer.link(SafeMath, FeedMaster);
  // deployer.link(SafeMath, ScarcityStore);
  // deployer.link(SafeMath, PythiaBank);

  // deployer.deploy(FeedMaster, { gas: 6721975 });
  // deployer.deploy(PythiaBank, { gas: 6721975 });
  // deployer.deploy(ScarcityStore, { gas: 6721975 });
  // deployer.deploy(Scarcity);
};
