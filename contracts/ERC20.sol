pragma solidity ^0.4.24;

import "./Ownable.sol";
import "./SafeMath.sol";

contract ERC20 is Ownable {

    using SafeMath for uint256;

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);

    mapping (address => uint256) private _balances;
    mapping (address => mapping (address => uint256)) private _allowed;

    string private _name;
    string private _ticker;
    uint private _totalSupply;
    uint8 private _decimals;

    constructor(string name, string ticker, uint totalSupply, uint8 decimals) public {
        _name = name;
        _ticker = ticker;
        _totalSupply = totalSupply;
        _decimals = decimals;
        _mint(owner(), _totalSupply);
    }

    function totalSupply() public view returns (uint256) {
        return _totalSupply;
    }

    function decimals() public view returns (uint8) {
        return _decimals;
    }

    function name() public view returns (string) {
        return _name;
    }

    function ticker() public view returns (string) {
        return _ticker;
    }

    function balanceOf(address owner) public view returns (uint256) {
        return _balances[owner];
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

    function _approve(address owner, address spender, uint256 value) internal {
        require(spender != address(0), "");
        require(owner != address(0), "");

        _allowed[owner][spender] = value;
        emit Approval(owner, spender, value);
    }

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
}
