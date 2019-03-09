const Token = artifacts.require("ERC20");

module.exports = function(deployer) {
  deployer.deploy(Token("keke", "kk", 10**30, 8));
};
