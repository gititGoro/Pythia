var AccessRestriction = artifacts.require("AccessRestriction");
var Pythia = artifacts.require("Pythia");
var PythiaBase = artifacts.require("PythiaBase");
var FeedMaster = artifacts.require("FeedMaster");
var OpenPredictions = artifacts.require("OpenPredictions");
var CircularBuffer = artifacts.require("CircularBufferLib");
var Judge = artifacts.require("Judge");
var KreshmoiHistory = artifacts.require("KreshmoiHistory");

module.exports = function (deployer) {
  deployer.deploy(AccessRestriction);
  deployer.deploy(PythiaBase);
  deployer.deploy(CircularBuffer);
  deployer.deploy(Judge);
  deployer.link(AccessRestriction, PythiaBase);
  deployer.link(AccessRestriction, FeedMaster);
  deployer.link(AccessRestriction, OpenPredictions);
  deployer.link(AccessRestriction, KreshmoiHistory);
  deployer.link(CircularBuffer, OpenPredictions);
  deployer.link(CircularBuffer, OpenPredictions);
  deployer.link(CircularBuffer, Judge);
  deployer.link(PythiaBase, Pythia);
  deployer.deploy(KreshmoiHistory);
  deployer.deploy(Pythia, { gas: 6000000 });
  deployer.deploy(FeedMaster, { gas: 6000000 });
  deployer.deploy(OpenPredictions, { gas: 6000000 });
};
