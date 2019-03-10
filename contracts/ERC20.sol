pragma solidity ^0.4.24;

import "./Ownable.sol";
import "./SafeMath.sol";

contract ERC20 is Ownable {

    using SafeMath for uint256;

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);

    mapping (address => uint256) private _balances;
    mapping (address => mapping (address => uint256)) private _allowed;

    bytes32 private _name;
    bytes32 private _ticker;
    uint private _totalSupply;
    uint8 private _decimals;

    constructor(bytes32 name, bytes32 ticker, uint totalSupply, uint8 decimals) public {
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

    function name() public view returns (bytes32) {
        return _name;
    }

    function ticker() public view returns (bytes32) {
        return _ticker;
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
        require(to != address(0), "");
        _balances[from] = _balances[from].sub(value);
        _balances[to] = _balances[to].add(value);
        emit Transfer(from, to, value);
    }

    function balanceOf(address owner) public view returns (uint256) {
        return _balances[owner];
    }

    function _mint(address _receiver, uint256 _value) internal {
        require(_receiver != address(0), "Error : account 0x0");

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
