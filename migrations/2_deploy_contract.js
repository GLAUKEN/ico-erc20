const Ownable = artifacts.require("Ownable");
const Reentrancy = artifacts.require("Reentrancy");
const SafeMath = artifacts.require("SafeMath");
const ERC20 = artifacts.require("ERC20");
const Crowdsale = artifacts.require("Crowdsale");

module.exports = function(deployer) {
  deployer.deploy(Ownable);
  deployer.deploy(Reentrancy);
  deployer.deploy(SafeMath);
  deployer.link(SafeMath, ERC20);
  deployer.deploy(ERC20, "PeakyCoin", "PC", 10**30, 8);
  deployer.deploy(Crowdsale);
};
