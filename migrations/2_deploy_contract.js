const Reentrancy = artifacts.require("ReentrancyGuard");
const SafeMath = artifacts.require("SafeMath");
const ERC20 = artifacts.require("ERC20");
const Crowdsale = artifacts.require("Crowdsale");

const name = "PeakyCoin";
const ticker = "PC";
const totalSupply = 10**30;
const decimals = 8;
const rate = 4;

module.exports = function(deployer, network, accounts) {
  
  //deployer.deploy(Reentrancy);
  deployer.deploy(SafeMath);
  deployer.link(SafeMath, ERC20);
  //deployer.deploy(ERC20, name, ticker, totalSupply, decimals).then(() => {
    //deployer.deploy(Crowdsale, rate, accounts[0], ERC20.address);
  //});
  deployer.deploy(ERC20, name, ticker, totalSupply, decimals, { gas: 5000000 });
};
