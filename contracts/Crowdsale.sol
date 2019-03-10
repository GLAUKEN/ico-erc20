pragma solidity ^0.4.24;

import "./Ownable.sol";
import "./ERC20.sol";
import "./ReentrancyGuard.sol";

contract Crowdsale is ReentrancyGuard, Ownable {
    using SafeMath for uint256;

    mapping (address => bool) private _whiteList;
    mapping (address => uint) private _privilegeRate;

    address[] public investors;

    ERC20 private _token;

    // Address where funds are collected
    address private _wallet;

    // rate = 4
    // decimals = 8
    // 1 wei = 0.00000004 token
    uint256 private _rate;

    uint256 private _weiRaised;

    event TokensPurchased(address indexed purchaser, address indexed beneficiary, uint256 value, uint256 amount);

    /**
     * @param wallet Address where collected funds will be forwarded to
     * @param token Address of the token being sold
     */
    constructor (uint256 rate, address wallet, ERC20 token) public {
        require(rate > 0, "rate is negative");
        require(wallet != address(0), "address 0x0");
        require(address(token) != address(0), "address 0x0");

        _rate = rate;
        _wallet = wallet;
        _token = token;
    }

    /**
     * @dev fallback function ***DO NOT OVERRIDE***
     * Note that other contracts will transfer funds with a base gas stipend
     * of 2300, which is not enough to call buyTokens. Consider calling
     * buyTokens directly when purchasing tokens from a contract.
     */
    function () external payable {
        buyTokens(msg.sender);
    }

    function token() public view returns (ERC20) {
        return _token;
    }

    function wallet() public view returns (address) {
        return _wallet;
    }

    function rate() public view returns (uint256) {
        return _rate;
    }

    function weiRaised() public view returns (uint256) {
        return _weiRaised;
    }

    modifier isWhiteListed(address _address) {
        require(_whiteList[_address], "not in whitelist");
        _;
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

    /**
     * @dev low level token purchase ***DO NOT OVERRIDE***
     * This function has a non-reentrancy guard, so it shouldn't be called by
     * another `nonReentrant` function.
     * @param beneficiary Recipient of the token purchase
     */
    function buyTokens(address beneficiary) public nonReentrant payable {
        uint256 weiAmount = msg.value;
        _preValidatePurchase(beneficiary, weiAmount);

        // calculate token amount to be created
        uint256 tokens = _getTokenAmount(weiAmount);

        // update state
        _weiRaised = _weiRaised.add(weiAmount);

        _processPurchase(beneficiary, tokens);
        emit TokensPurchased(msg.sender, beneficiary, weiAmount, tokens);
        _forwardFunds();
    }

    function airdrop(uint _value) external onlyOwner() returns (bool success) {
        require(_balances[owner()] >= _value * investors.length, "airdrop fail, balance insufficient");
        for (uint8 i = 0; i < investors.length; i++) {
            transferFrom(owner(), investors[i], _value);
        }
        return true;
    }


    /**
     * @dev Validation of an incoming purchase. Use require statements to revert state when conditions are not met.
     * Use `super` in contracts that inherit from Crowdsale to extend their validations.
     * Example from CappedCrowdsale.sol's _preValidatePurchase method:
     *     super._preValidatePurchase(beneficiary, weiAmount);
     *     require(weiRaised().add(weiAmount) <= cap);
     * @param beneficiary Address performing the token purchase
     * @param weiAmount Value in wei involved in the purchase
     */
    function _preValidatePurchase(address beneficiary, uint256 weiAmount) internal pure {
        require(beneficiary != address(0), "address 0x0");
        require(weiAmount != 0, "Wei amount = 0");
    }

    /**
     * @dev Source of tokens. Override this method to modify the way in which the crowdsale ultimately gets and sends
     * its tokens.
     * @param beneficiary Address performing the token purchase
     * @param tokenAmount Number of tokens to be emitted
     */
    function _deliverTokens(address beneficiary, uint256 tokenAmount) internal {
        _token.transferFrom(owner(), beneficiary, tokenAmount);
    }

    /**
     * @dev Executed when a purchase has been validated and is ready to be executed. Doesn't necessarily emit/send
     * tokens.
     * @param beneficiary Address receiving the tokens
     * @param tokenAmount Number of tokens to be purchased
     */
    function _processPurchase(address beneficiary, uint256 tokenAmount) internal {
        _deliverTokens(beneficiary, tokenAmount);
    }

    /**
     * @dev Override to extend the way in which ether is converted to tokens.
     * @param weiAmount Value in wei to be converted into tokens
     * @return Number of tokens that can be purchased with the specified _weiAmount
     */
    function _getTokenAmount(uint256 weiAmount) internal view returns (uint256) {
        return weiAmount.mul(_rate);
    }

    /**
     * @dev Determines how ETH is stored/forwarded on purchases.
     */
    function _forwardFunds() internal {
        _wallet.transfer(msg.value);
    }
}