const SafeMath = artifacts.require("SafeMath");
const ERC20 = artifacts.require("ERC20");
const Crowdsale = artifacts.require("Crowdsale");

const name = "PeakyCoin";
const ticker = "PC";
const totalSupply = 10**30;
const decimals = 8;
const rate = 4;

module.exports = function(deployer, network, accounts) {

  if (network === "development") {
    return deployer
    .then(() => deployer.deploy(SafeMath))
    .then(() => deployer.link(SafeMath, ERC20))
    .then(() => deployer.deploy(ERC20, name, ticker, totalSupply, decimals))
    .then(() => deployer.deploy(Crowdsale, rate, ERC20.address))
    .then(() => Crowdsale.deployed())
    .then(crowdsaleInstance => {
      crowdsaleInstance.addToWhitelist(accounts[1]);
      crowdsaleInstance.addToWhitelist(accounts[2]);
      crowdsaleInstance.buyTokens(accounts[1], { from : accounts[1], value : 10000000 });
    });
  }

  if (network === "ropsten") {
    return deployer
    .then(() => deployer.deploy(SafeMath))
    .then(() => deployer.link(SafeMath, ERC20))
    .then(() => deployer.deploy(ERC20, name, ticker, totalSupply, decimals))
    .then(() => deployer.deploy(Crowdsale, rate, ERC20.address))
  }

};