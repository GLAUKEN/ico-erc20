pragma solidity ^0.4.24;

import "./ERC20.sol";

contract Crowdsale {

    using SafeMath for uint256;

    event TokensPurchased(address indexed purchaser, address indexed beneficiary, uint value, uint amount);
    event WhitelistedAdded(address indexed account);
    event PrivilegedAdded(address indexed account, uint rate);
    event PrivilegedRemoved(address indexed account);
    event AirdropSuccessful(uint value);

    mapping (address => bool) private _whitelist;
    mapping (address => uint) private _privilegeRate;

    address[] public investors;

    ERC20 private _token;

    address private _owner;

    // rate = 4
    // decimals = 8
    // 1 wei = 0.00000004 token
    uint private _rate;
    uint private _weiRaised;

    constructor (uint rate, ERC20 token) public {
        require(rate > 0, "rate is negative");
        require(address(token) != address(0), "address 0x0");

        _owner = msg.sender;
        _rate = rate;
        _token = token;
    }

    function () external payable {
        buyTokens(msg.sender);
    }

    function token() public view returns (ERC20) {
        return _token;
    }

    function owner() public view returns (address) {
        return _owner;
    }

    function rate() public view returns (uint) {
        return _rate;
    }

    function weiRaised() public view returns (uint) {
        return _weiRaised;
    }

    modifier onlyOwner() {
        require(msg.sender == _owner, "Owner 0x0");
        _;
    }

    modifier isWhitelisted(address _address) {
        require(_whitelist[_address], "not in whitelist");
        _;
    }

    modifier isNotZeroAccount(address _address) {
        require(_address != address(0), "address 0x0");
        _;
    }

    function _addToWhiteList(address _address) public onlyOwner() isNotZeroAccount(_address) {
        require(!_whitelist[_address], "aldready in whitelist");
        _whitelist[_address] = true;
        investors.push(_address);
        emit WhitelistedAdded(_address);
    }

    function _addPrivilege(address _address, uint _privilegedRate) public onlyOwner() isWhitelisted(_address) isNotZeroAccount(_address) {
        _privilegeRate[_address] = _privilegedRate;
        emit PrivilegedAdded(_address, _privilegedRate);
    }

    function _removePrivilege(address _address) public onlyOwner() {
        require(_privilegeRate[_address] != 0, "not a privileged one");
        delete _privilegeRate[_address];
        emit PrivilegedRemoved(_address);
    }

    function airdrop(uint _value) external onlyOwner() {
        require(_token.balanceOf(_owner) >= _value * investors.length, "airdrop fail, balance insufficient");
        for (uint8 i = 0; i < investors.length; i++) {
            _token.transferFrom(_owner, investors[i], _value);
        }
        emit AirdropSuccessful(_value);
    }

    function buyTokens(address beneficiary) public payable {
        uint weiAmount = msg.value;
        _preValidatePurchase(beneficiary, weiAmount);
        uint tokens = _getTokenAmount(beneficiary, weiAmount);
        _weiRaised = _weiRaised.add(weiAmount);
        _processPurchase(beneficiary, tokens);
        emit TokensPurchased(msg.sender, beneficiary, weiAmount, tokens);
        _forwardFunds();
    }

    function _preValidatePurchase(address beneficiary, uint weiAmount) internal pure {
        require(beneficiary != address(0), "address 0x0");
        require(weiAmount != 0, "Wei amount = 0");
    }

    function _deliverTokens(address beneficiary, uint tokenAmount) internal {
        _token.transferFrom(_owner, beneficiary, tokenAmount);
    }

    function _processPurchase(address beneficiary, uint tokenAmount) internal {
        _deliverTokens(beneficiary, tokenAmount);
    }

    function _getTokenAmount(address _address, uint weiAmount) internal view returns (uint) {
        return (_privilegeRate[_address] == 0) ? weiAmount.mul(_rate) : (weiAmount.mul(_rate) * _privilegeRate[_address]);
    }

    function _forwardFunds() internal {
        _owner.transfer(msg.value);
    }
}
