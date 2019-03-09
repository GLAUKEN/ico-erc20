const ERC20 = artifacts.require("ERC20");
const SafeMath = artifacts.require("SafeMath");

module.exports = function(deployer) {
  deployer.deploy(SafeMath);
  deployer.link(SafeMath, ERC20);
  deployer.deploy(ERC20);
};
