// SPDX-License-Identifier: MIT

pragma solidity =0.8.17;

import "./@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "./@openzeppelin/contracts/access/Ownable.sol";

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
