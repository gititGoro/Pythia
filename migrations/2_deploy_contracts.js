var AccessRestriction = artifacts.require("AccessRestriction");
var FeedMaster = artifacts.require("FeedMaster");
var CircularBuffer = artifacts.require("CircularBufferLib");
var SafeMath = artifacts.require("SafeMath");
var Scarcity = artifacts.require("Scarcity");
var PythiaBank = artifacts.require("PythiaBank");

module.exports = function (deployer) {
  deployer.deploy(AccessRestriction, { gas: 6721975 });
  deployer.deploy(CircularBuffer, { gas: 6721975 });
  deployer.deploy(SafeMath, { gas: 6721975 });
  deployer.link(AccessRestriction, FeedMaster);
  deployer.link(AccessRestriction, Scarcity);
  deployer.link(AccessRestriction, PythiaBank);
  deployer.link(SafeMath, FeedMaster);
  deployer.link(SafeMath, Scarcity);
  deployer.link(SafeMath, PythiaBank);
  deployer.deploy(FeedMaster, { gas: 6721975 });
  deployer.deploy(PythiaBank, { gas: 6721975 });
  deployer.deploy(Scarcity, { gas: 6721975 });
};
