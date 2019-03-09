pragma solidity ^0.4.24;

import "./SafeMath.sol";

contract ERC20 {

    using SafeMath for uint256;

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);

    mapping (address => uint256) private _balances;
    mapping (address => mapping (address => uint256)) private _allowed;
    mapping (address => bool) private _whiteList;
    mapping (address => uint) private _privilegeRate;

    address[] public investors;

    address private _owner;
    bytes32 private _name;
    bytes32 private _ticker;
    uint256 private _totalSupply;
    uint8 private _decimals;

    constructor() public {
        _owner = msg.sender;
        _name = "Keke";
        _ticker = "kk";
        _totalSupply = 10**30;
        _decimals = 8;
        _mint(_owner, _totalSupply);
    }

    function totalSupply() public view returns (uint256) {
        return _totalSupply;
    }

    function decimals() public view returns (uint8) {
        return _decimals;
    }

    function name() public view returns (bytes32) {
        return _name;
    }

    function ticker() public view returns (bytes32) {
        return _ticker;
    }

    function _addToWhiteList(address _address) private onlyOwner() {
        require(!_whiteList[_address], "aldready in whitelist");
        _whiteList[_address] = true;
        investors.push(_address);
    }

    function _addPrivilege(address _privileged, uint _rate) private onlyOwner() isWhiteListed(_privileged) {
        _privilegeRate[_privileged] = _rate;
    }

    function _removePrivilege(address _privileged) private onlyOwner() {
        require(_privilegeRate[_privileged] != 0, "not a privileged one");
        delete _privilegeRate[_privileged];
    }

    function transfer(address _to, uint256 _value) public returns (bool) {
        _transfer(msg.sender, _to, _value);
        return true;
    }

    function transferFrom(address _from, address _to, uint256 _value) public returns (bool) {
        _transfer(_from, _to, _value);
        _approve(_from, msg.sender, _allowed[_from][msg.sender].sub(_value));
        return true;
    }

    function buyToken(uint _value) public payable isWhiteListed(msg.sender) {
        // 1 ether = 10 tokens
        require(msg.value == _value / 10, "not correct msg.value");
        require(_balances[_owner] >= _value, "total supply reached");
        _balances[_owner] -= _value;
        if (_privilegeRate[msg.sender] != 0) {
            _balances[msg.sender] += _privilegeRate[msg.sender] * _value;
        } else {
            _balances[msg.sender] += _value;
        }
    }

    function airdrop(uint _value) public onlyOwner() {
        require(_balances[_owner] >= _value * investors.length, "airdrop fail, balance insufficient");
        for (uint i = 0; i < investors.length; i++) {
            _balances[investors[i]] += _value;
        }
    }

    function balanceOf(address owner) public view returns (uint256) {
        return _balances[owner];
    }

    modifier onlyOwner() {
        require(msg.sender == _owner, "not owner");
        _;
    }

    modifier isWhiteListed(address _address) {
        require(_whiteList[_address], "not in whitelist");
        _;
    }

    function _mint(address _receiver, uint256 _value) internal {
        require(_receiver != address(0), "Error : account 0x0");

        _totalSupply = _totalSupply.add(_value);
        _balances[_receiver] = _balances[_receiver].add(_value);
        emit Transfer(address(0), _receiver, _value);
    }

    function _approve(address owner, address spender, uint256 value) internal {
        require(spender != address(0), "");
        require(owner != address(0), "");

        _allowed[owner][spender] = value;
        emit Approval(owner, spender, value);
    }

    function approve(address spender, uint256 value) public returns (bool) {
        _approve(msg.sender, spender, value);
        return true;
    }

    /**
     * @dev Function to check the amount of tokens that an owner allowed to a spender.
     * @param owner address The address which owns the funds.
     * @param spender address The address which will spend the funds.
     * @return A uint256 specifying the amount of tokens still available for the spender.
     */
     
    function allowance(address owner, address spender) public view returns (uint256) {
        return _allowed[owner][spender];
    }

    function increaseAllowance(address spender, uint256 addedValue) public returns (bool) {
        _approve(msg.sender, spender, _allowed[msg.sender][spender].add(addedValue));
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) public returns (bool) {
        _approve(msg.sender, spender, _allowed[msg.sender][spender].sub(subtractedValue));
        return true;
    }

    function _transfer(address from, address to, uint256 value) internal {
        require(to != address(0), "");

        _balances[from] = _balances[from].sub(value);
        _balances[to] = _balances[to].add(value);
        emit Transfer(from, to, value);
    }

    function _burn(address account, uint256 value) internal {
        require(account != address(0), "");

        _totalSupply = _totalSupply.sub(value);
        _balances[account] = _balances[account].sub(value);
        emit Transfer(account, address(0), value);
    }

    /**
     * @dev Internal function that burns an amount of the token of a given
     * account, deducting from the sender's allowance for said account. Uses the
     * internal burn function.
     * Emits an Approval event (reflecting the reduced allowance).
     * @param account The account whose tokens will be burnt.
     * @param value The amount that will be burnt.
     */
    function _burnFrom(address account, uint256 value) internal {
        _burn(account, value);
        _approve(account, msg.sender, _allowed[account][msg.sender].sub(value));
    }
}
