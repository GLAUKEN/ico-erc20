pragma solidity ^0.4.24;

import "./SafeMath.sol";

contract ERC20 {

    using SafeMath for uint256;

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);

    mapping (address => uint256) private _balances;
    mapping (address => mapping (address => uint256)) private _allowed;
    
    address private _owner;
    bytes32 private _name;
    bytes32 private _ticker;
    uint private _totalSupply;
    uint8 private _decimals;

    constructor(bytes32 name, bytes32 ticker, uint totalSupply, uint8 decimals) public {
        _owner = msg.sender;
        _name = name;
        _ticker = ticker;
        _totalSupply = totalSupply;
        _decimals = decimals;
        _mint(_owner, _totalSupply);
    }

    function owner() public view returns (address) {
        return _owner;
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

    function balanceOf(address _address) public view returns (uint256) {
        return _balances[_address];
    }

    modifier onlyOwner() {
        require(msg.sender == _owner, "Owner 0x0");
        _;
    }

    function transfer(address _to, uint256 _value) public returns (bool) {
        _transfer(msg.sender, _to, _value);
        return true;
    }

    function transferFrom(address _from, address _to, uint256 _value) public returns (bool) {
        _transfer(_from, _to, _value);
        return true;
    }

    function _transfer(address from, address to, uint256 value) private {
        require(to != address(0), "address 0x0");
        _balances[from] = _balances[from].sub(value);
        _balances[to] = _balances[to].add(value);
        emit Transfer(from, to, value);
    }

    function _mint(address _receiver, uint256 _value) internal onlyOwner() {
        require(_receiver != address(0), "address 0x0");
        _totalSupply = _totalSupply.add(_value);
        _balances[_receiver] = _balances[_receiver].add(_value);
        emit Transfer(address(0), _receiver, _value);
    }

    function approve(address spender, uint256 value) public returns (bool) {
        _approve(msg.sender, spender, value);
        return true;
    }

    function _approve(address sender, address spender, uint256 value) internal {
        require(spender != address(0), "address 0x0");
        require(sender != address(0), "address 0x0");

        _allowed[sender][spender] = value;
        emit Approval(sender, spender, value);
    }

    function allowance(address sender, address spender) public view returns (uint256) {
        return _allowed[sender][spender];
    }

    function increaseAllowance(address spender, uint256 addedValue) public returns (bool) {
        _approve(msg.sender, spender, _allowed[msg.sender][spender].add(addedValue));
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) public returns (bool) {
        _approve(msg.sender, spender, _allowed[msg.sender][spender].sub(subtractedValue));
        return true;
    }
}
