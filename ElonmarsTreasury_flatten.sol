// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (utils/Context.sol)

pragma solidity =0.8.17;

/**
 * @dev Provides information about the current execution context, including the
 * sender of the transaction and its data. While these are generally available
 * via msg.sender and msg.data, they should not be accessed in such a direct
 * manner, since when dealing with meta-transactions the account sending and
 * paying for execution may not be the actual sender (as far as an application
 * is concerned).
 *
 * This contract is only required for intermediate, library-like contracts.
 */
abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}


// File contracts/@openzeppelin/contracts/access/Ownable.sol

// OpenZeppelin Contracts (last updated v4.7.0) (access/Ownable.sol)

/**
 * @dev Contract module which provides a basic access control mechanism, where
 * there is an account (an owner) that can be granted exclusive access to
 * specific functions.
 *
 * By default, the owner account will be the one that deploys the contract. This
 * can later be changed with {transferOwnership}.
 *
 * This module is used through inheritance. It will make available the modifier
 * `onlyOwner`, which can be applied to your functions to restrict their use to
 * the owner.
 */
abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor() {
        _transferOwnership(_msgSender());
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        _checkOwner();
        _;
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view virtual returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if the sender is not the owner.
     */
    function _checkOwner() internal view virtual {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
    }

    /**
     * @dev Leaves the contract without owner. It will not be possible to call
     * `onlyOwner` functions anymore. Can only be called by the current owner.
     *
     * NOTE: Renouncing ownership will leave the contract without an owner,
     * thereby removing any functionality that is only available to the owner.
     */
    function renounceOwnership() public virtual onlyOwner {
        _transferOwnership(address(0));
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _transferOwnership(newOwner);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Internal function without access restriction.
     */
    function _transferOwnership(address newOwner) internal virtual {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}


// File contracts/@openzeppelin/contracts/token/ERC20/IERC20.sol

// OpenZeppelin Contracts (last updated v4.6.0) (token/ERC20/IERC20.sol)

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */
interface IERC20 {
    /**
     * @dev Emitted when `value` tokens are moved from one account (`from`) to
     * another (`to`).
     *
     * Note that `value` may be zero.
     */
    event Transfer(address indexed from, address indexed to, uint256 value);

    /**
     * @dev Emitted when the allowance of a `spender` for an `owner` is set by
     * a call to {approve}. `value` is the new allowance.
     */
    event Approval(address indexed owner, address indexed spender, uint256 value);

    /**
     * @dev Returns the amount of tokens in existence.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the amount of tokens owned by `account`.
     */
    function balanceOf(address account) external view returns (uint256);

    /**
     * @dev Moves `amount` tokens from the caller's account to `to`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transfer(address to, uint256 amount) external returns (bool);

    /**
     * @dev Returns the remaining number of tokens that `spender` will be
     * allowed to spend on behalf of `owner` through {transferFrom}. This is
     * zero by default.
     *
     * This value changes when {approve} or {transferFrom} are called.
     */
    function allowance(address owner, address spender) external view returns (uint256);

    /**
     * @dev Sets `amount` as the allowance of `spender` over the caller's tokens.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * IMPORTANT: Beware that changing an allowance with this method brings the risk
     * that someone may use both the old and the new allowance by unfortunate
     * transaction ordering. One possible solution to mitigate this race
     * condition is to first reduce the spender's allowance to 0 and set the
     * desired value afterwards:
     * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
     *
     * Emits an {Approval} event.
     */
    function approve(address spender, uint256 amount) external returns (bool);

    /**
     * @dev Moves `amount` tokens from `from` to `to` using the
     * allowance mechanism. `amount` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool);
}


// File contracts/ElonmarsTreasury.sol

contract ElonmarsTreasury is Ownable {
    // config
    IERC20 public spxToken = IERC20(0xc6D542Ab6C9372a1bBb7ef4B26528039fEE5C09B);
    IERC20 public feeToken = IERC20(0xe9e7CEA3DedcA5984780Bafc599bD69ADd087D56);
    IERC20 public premiumToken =
        IERC20(0xe9e7CEA3DedcA5984780Bafc599bD69ADd087D56);
    address public admin = 0x2faf8ab2b9ac8Bd4176A0B9D31502bA3a59B4b41; // Test
    uint256 public minDeposit = 320 * 10 ** 9; // 320 SPX
    uint256 public premiumPrice = 15 ether; // 15 BUSD
    uint256 public fee = 1 ether; // 1 BUSD

    // global info
    uint256 public totalDepositedSpx;
    uint256 public totalWithdrawnSpx;
    uint256 public totalPaidFeeAmount;

    // user info
    mapping(address => address) public referral;
    mapping(address => uint256) public depositedSpx;
    mapping(address => uint256) public withdrawnSpx;
    mapping(address => uint256) public paidFeeAmount;
    mapping(address => uint256) public premiumTimestamp;
    mapping(address => uint256) public paidAmountForPremium;

    // withdraw track
    mapping(uint256 => uint256) public requestAmount;
    mapping(uint256 => address) public requestUser;
    uint256 nonceRequest;
    uint256 nonceWithdrawn;

    // deposit track
    mapping(uint256 => uint256) public depositAmount;
    mapping(uint256 => address) public depositUser;
    uint256 nonceDeposit;

    // premium track
    uint256 noncePremium;

    // event
    event LogDeposit(address indexed user, uint256 nonce, uint256 amount);
    event LogWithdrawRequest(
        address indexed user,
        uint256 indexed nonce,
        uint256 amount,
        uint256 feeAmount
    );
    event LogWithdraw(
        address indexed user,
        uint256 indexed nonce,
        uint256 amount
    );
    event LogBuyPremium(
        address indexed user,
        uint256 indexed nonce,
        uint256 timestamp
    );

    function deposit(uint256 amount, address _referral) external {
        require(amount >= minDeposit, "Insufficient deposit amount");

        spxToken.transferFrom(msg.sender, address(this), amount);
        if (referral[msg.sender] == address(0) && _referral != msg.sender) {
            referral[msg.sender] = _referral == address(0) ? admin : _referral;
        }
        depositedSpx[msg.sender] += amount;

        nonceDeposit++;
        depositAmount[nonceDeposit] = amount;
        depositUser[nonceDeposit] = msg.sender;

        emit LogDeposit(msg.sender, nonceDeposit, amount);
    }

    function buyPremium() external {
        premiumToken.transferFrom(msg.sender, address(this), premiumPrice);

        premiumTimestamp[msg.sender] = block.timestamp;
        paidAmountForPremium[msg.sender] += premiumPrice;

        noncePremium++;

        emit LogBuyPremium(msg.sender, noncePremium, block.timestamp);
    }

    function withdrawRequest(uint256 amount) external {
        require(amount > 0, "Invalid Amount");
        feeToken.transferFrom(msg.sender, address(this), fee);

        paidFeeAmount[msg.sender] += fee;

        nonceRequest++;
        requestAmount[nonceRequest] = amount;
        requestUser[nonceRequest] = msg.sender;

        emit LogWithdrawRequest(msg.sender, nonceRequest, amount, fee);
    }

    function withdraw() external {
        require(msg.sender == admin, "Invalid Admin");
        require(nonceRequest > nonceWithdrawn, "No Pending Request");

        nonceWithdrawn++;
        withdrawnSpx[msg.sender] += requestAmount[nonceWithdrawn];
        spxToken.transfer(
            requestUser[nonceWithdrawn],
            requestAmount[nonceWithdrawn]
        );

        emit LogWithdraw(
            msg.sender,
            nonceWithdrawn,
            requestAmount[nonceWithdrawn]
        );
    }

    function updateSpxToken(IERC20 _spxToken) external onlyOwner {
        spxToken = _spxToken;
    }

    function updateFeeToken(IERC20 _feeToken) external onlyOwner {
        feeToken = _feeToken;
    }

    function updateAdmin(address _admin) external onlyOwner {
        admin = _admin;
    }

    function updateFee(uint256 _fee) external onlyOwner {
        fee = _fee;
    }

    function updateMinDeposit(uint256 _minDeposit) external onlyOwner {
        minDeposit = _minDeposit;
    }

    function updatePremiumToken(IERC20 _premiumToken) external onlyOwner {
        premiumToken = _premiumToken;
    }

    function updatePremiumToken(uint256 _premiumPrice) external onlyOwner {
        premiumPrice = _premiumPrice;
    }

    function withdrawByAdmin(
        IERC20 token,
        address to,
        uint256 amount
    ) external {
        require(msg.sender == admin, "Invalid Admin");

        token.transfer(to, amount);
    }
}
