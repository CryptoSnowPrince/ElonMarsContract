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
    address public fundsAdmin = 0x2faf8ab2b9ac8Bd4176A0B9D31502bA3a59B4b41; // CONFIG
    address public admin = 0x2faf8ab2b9ac8Bd4176A0B9D31502bA3a59B4b41; // CONFIG
    uint256 public minDeposit = 320 * 10 ** 9; // 320 SPX
    uint256 public fee = 1 ether; // withdraw fee: 1 BUSD
    uint256 public dailyLimitUSD = 5 * 10 ** 18; // $5(5 BUSD)
    uint256 public dailyPremiumLimitUSD = 10 * 10 ** 18; // $10(5 BUSD)
    uint256 public limitDuration = 86400; // 1 day
    IERC20 public WBNB = IERC20(0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c);
    IERC20 public BUSD = IERC20(0xe9e7CEA3DedcA5984780Bafc599bD69ADd087D56);
    address public WbnbBusdV2Pair = 0x58F876857a02D6762E0101bb5C46A8c1ED44Dc16;
    address public WbnbSpxV2Pair = 0xA36624401BA2a19b819ff41fE954673F49631F8a;
    uint256 public premiumPrice = 15 ether; // 15 BUSD
    uint256 public premiumDuration = 30 * 86400; // 30 days
    uint256 public miningPrice = 8100 * 10 ** 9; // 8100 SPX
    uint256 public plantPrice = 40000 * 10 ** 9; // 40000 SPX
    uint256 public goldPrice = 5040 * 10 ** 9; // 5040 SPX
    uint256 public uranPrice = 6700 * 10 ** 9; // 6700 SPX
    uint256 public land1Price = 4320 * 10 ** 9; // 4320 SPX
    uint256 public land2Price = 1000 * 10 ** 9; // 1000 SPX
    uint256 public land3Price = 3240 * 10 ** 9; // 3240 SPX

    // global info
    uint256 public totalDepositedSpx; // SPX amount
    uint256 public totalWithdrawnSpx; // SPX amount
    uint256 public totalPaidFeeAmount; // BUSD amount
    uint256 public totalPremiumAmount; // BUSD amount
    uint256 public totalMiningAmount; // SPX amount
    uint256 public totalPlantAmount; // SPX amount
    uint256 public totalGoldAmount; // SPX amount
    uint256 public totalUranAmount; // SPX amount
    uint256 public totalLand1Amount; // SPX amount
    uint256 public totalLand2Amount; // SPX amount
    uint256 public totalLand3Amount; // SPX amount

    // user info
    // referral
    mapping(address => address) public referral;
    // deposit
    mapping(address => uint256) public depositedSpx;
    // withdraw
    mapping(address => uint256) public withdrawnSpx;
    mapping(address => uint256) public paidFeeAmount;
    // premium
    mapping(address => uint256) public premiumTimestamp;
    mapping(address => uint256) public amountForPremium;
    // mining
    mapping(address => uint256) public amountForMining;
    // plant
    mapping(address => uint256) public amountForPlant;
    // gold
    mapping(address => uint256) public amountForGold;
    // uran
    mapping(address => uint256) public amountForUran;
    // land1
    mapping(address => uint256) public amountForLand1;
    // land2
    mapping(address => uint256) public amountForLand2;
    // land3
    mapping(address => uint256) public amountForLand3;

    // track info
    // withdraw track
    mapping(uint256 => uint256) public requestAmount;
    mapping(uint256 => address) public requestUser;
    uint256 public nonceRequest;
    uint256 public nonceWithdrawn;
    // deposit track
    mapping(uint256 => uint256) public depositAmount;
    mapping(uint256 => address) public depositUser;
    uint256 public nonceDeposit;
    // premium track
    uint256 public noncePremium;
    // mining track
    uint256 public nonceMining;
    // plant track
    uint256 public noncePlant;
    // gold track
    uint256 public nonceGold;
    // uran track
    uint256 public nonceUran;
    // land1 track
    uint256 public nonceLand1;
    // land2 track
    uint256 public nonceLand2;
    // land3 track
    uint256 public nonceLand3;

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
        uint256 timestamp,
        uint256 amount
    );
    event LogBuyMining(
        address indexed user,
        uint256 indexed nonce,
        uint256 amount
    );
    event LogBuyPlant(
        address indexed user,
        uint256 indexed nonce,
        uint256 amount
    );
    event LogBuyGold(
        address indexed user,
        uint256 indexed nonce,
        uint256 amount
    );
    event LogBuyUran(
        address indexed user,
        uint256 indexed nonce,
        uint256 amount
    );
    event LogBuyLand1(
        address indexed user,
        uint256 indexed nonce,
        uint256 amount
    );
    event LogBuyLand2(
        address indexed user,
        uint256 indexed nonce,
        uint256 amount
    );
    event LogBuyLand3(
        address indexed user,
        uint256 indexed nonce,
        uint256 amount
    );

    function deposit(uint256 amount, address _referral) external {
        require(amount >= minDeposit, "Insufficient deposit amount");

        require(
            spxToken.transferFrom(msg.sender, address(this), amount),
            "Faild TransferFrom"
        );
        if (referral[msg.sender] == address(0) && _referral != msg.sender) {
            referral[msg.sender] = _referral == address(0) ? admin : _referral;
        }
        depositedSpx[msg.sender] += amount;

        nonceDeposit++;
        depositAmount[nonceDeposit] = amount;
        depositUser[nonceDeposit] = msg.sender;

        totalDepositedSpx += amount;

        emit LogDeposit(msg.sender, nonceDeposit, amount);
    }

    function buyPremium() external {
        require(
            premiumToken.transferFrom(msg.sender, address(this), premiumPrice),
            "Faild TransferFrom"
        );

        if (premiumTimestamp[msg.sender] < block.timestamp) {
            premiumTimestamp[msg.sender] = block.timestamp + premiumDuration;
        } else {
            premiumTimestamp[msg.sender] += premiumDuration;
        }
        amountForPremium[msg.sender] += premiumPrice;

        noncePremium++;

        totalPremiumAmount += premiumPrice;

        emit LogBuyPremium(
            msg.sender,
            noncePremium,
            block.timestamp,
            premiumPrice
        );
    }

    function buyMining() external {
        require(amountForMining[msg.sender] < miningPrice, "Already Purchased");
        uint256 amount = miningPrice - amountForMining[msg.sender];
        require(
            spxToken.transferFrom(msg.sender, address(this), amount),
            "Faild TransferFrom"
        );

        amountForMining[msg.sender] += amount;

        nonceMining++;

        totalMiningAmount += amount;

        emit LogBuyMining(msg.sender, nonceMining, amount);
    }

    function buyPlant() external {
        require(amountForPlant[msg.sender] < plantPrice, "Already Purchased");
        uint256 amount = plantPrice - amountForPlant[msg.sender];
        require(
            spxToken.transferFrom(msg.sender, address(this), amount),
            "Faild TransferFrom"
        );

        amountForPlant[msg.sender] += amount;

        noncePlant++;

        totalPlantAmount += amount;

        emit LogBuyPlant(msg.sender, noncePlant, amount);
    }

    function buyGold() external {
        require(amountForGold[msg.sender] < goldPrice, "Already Purchased");
        uint256 amount = goldPrice - amountForGold[msg.sender];
        require(
            spxToken.transferFrom(msg.sender, address(this), amount),
            "Faild TransferFrom"
        );

        amountForGold[msg.sender] += amount;

        nonceGold++;

        totalGoldAmount += amount;

        emit LogBuyGold(msg.sender, nonceGold, amount);
    }

    function buyUran() external {
        require(amountForUran[msg.sender] < uranPrice, "Already Purchased");
        uint256 amount = uranPrice - amountForUran[msg.sender];
        require(
            spxToken.transferFrom(msg.sender, address(this), amount),
            "Faild TransferFrom"
        );

        amountForUran[msg.sender] += amount;

        nonceUran++;

        totalUranAmount += amount;

        emit LogBuyUran(msg.sender, nonceUran, amount);
    }

    function buyLand1() external {
        require(amountForLand1[msg.sender] < land1Price, "Already Purchased");
        uint256 amount = land1Price - amountForLand1[msg.sender];
        require(
            spxToken.transferFrom(msg.sender, address(this), amount),
            "Faild TransferFrom"
        );

        amountForLand1[msg.sender] += amount;

        nonceLand1++;

        totalLand1Amount += amount;

        emit LogBuyLand1(msg.sender, nonceLand1, amount);
    }

    function buyLand2() external {
        require(amountForLand2[msg.sender] < land2Price, "Already Purchased");
        uint256 amount = land2Price - amountForLand2[msg.sender];
        require(
            spxToken.transferFrom(msg.sender, address(this), amount),
            "Faild TransferFrom"
        );

        amountForLand2[msg.sender] += amount;

        nonceLand2++;

        totalLand2Amount += amount;

        emit LogBuyLand2(msg.sender, nonceLand2, amount);
    }

    function buyLand3() external {
        require(amountForLand3[msg.sender] < land3Price, "Already Purchased");
        uint256 amount = land3Price - amountForLand3[msg.sender];
        require(
            spxToken.transferFrom(msg.sender, address(this), amount),
            "Faild TransferFrom"
        );

        amountForLand3[msg.sender] += amount;

        nonceLand3++;

        totalLand3Amount += amount;

        emit LogBuyLand3(msg.sender, nonceLand3, amount);
    }

    function getDailyLimitSpx(address user) public view returns (uint256) {
        uint256 _dailyLimitUSD = dailyLimitUSD;
        if (premiumTimestamp[user] > block.timestamp) {
            _dailyLimitUSD = dailyPremiumLimitUSD;
        }
        uint256 _busdBalOfBnbBusd = BUSD.balanceOf(WbnbBusdV2Pair);
        uint256 _wbnbBalOfBnbBusd = WBNB.balanceOf(WbnbBusdV2Pair);
        uint256 _wbnbBalOfBnbSpx = WBNB.balanceOf(WbnbSpxV2Pair);
        uint256 _spxBalOfBnbSpx = spxToken.balanceOf(WbnbSpxV2Pair);

        uint256 _dailyLimitBNB = (_dailyLimitUSD * _wbnbBalOfBnbBusd * 10000) /
            _busdBalOfBnbBusd;
        uint256 _dailyLimitSPX = (_dailyLimitBNB * _spxBalOfBnbSpx) /
            (_wbnbBalOfBnbSpx * 10000);

        return _dailyLimitSPX;
    }

    function getDailyWithdrawnSpx(address user) public view returns (uint256) {}

    function getDailyRemainSpx(address user) public view returns (uint256) {
        return (getDailyLimitSpx(user) - getDailyWithdrawnSpx(user));
    }

    // TODO withdraw limit check
    function withdrawRequest(uint256 amount) external {
        require(amount > 0, "Invalid Amount");
        require(
            feeToken.transferFrom(msg.sender, address(this), fee),
            "Faild TransferFrom"
        );

        paidFeeAmount[msg.sender] += fee;

        nonceRequest++;
        requestAmount[nonceRequest] = amount;
        requestUser[nonceRequest] = msg.sender;

        totalPaidFeeAmount += fee;

        emit LogWithdrawRequest(msg.sender, nonceRequest, amount, fee);
    }

    // TODO withdraw limit check
    function withdraw() external {
        require(msg.sender == admin, "Invalid Admin");
        require(nonceRequest > nonceWithdrawn, "No Pending Request");

        nonceWithdrawn++;
        withdrawnSpx[msg.sender] += requestAmount[nonceWithdrawn];
        spxToken.transfer(
            requestUser[nonceWithdrawn],
            requestAmount[nonceWithdrawn]
        );

        totalWithdrawnSpx += requestAmount[nonceWithdrawn];

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

    function updateFundsAdmin(address _fundsAdmin) external onlyOwner {
        fundsAdmin = _fundsAdmin;
    }

    function updateMinDeposit(uint256 _minDeposit) external onlyOwner {
        minDeposit = _minDeposit;
    }

    function updateFee(uint256 _fee) external onlyOwner {
        fee = _fee;
    }

    function updateDailyLimitUSD(uint256 _dailyLimitUSD) external onlyOwner {
        dailyLimitUSD = _dailyLimitUSD;
    }

    function updateDailyPremiumLimitUSD(
        uint256 _dailyPremiumLimitUSD
    ) external onlyOwner {
        dailyPremiumLimitUSD = _dailyPremiumLimitUSD;
    }

    function updateLimitDuration(uint256 _limitDuration) external onlyOwner {
        limitDuration = _limitDuration;
    }

    function updateWBNB(IERC20 _wbnb) external onlyOwner {
        WBNB = _wbnb;
    }

    function updateBUSD(IERC20 _busd) external onlyOwner {
        BUSD = _busd;
    }

    function updateWbnbBusdV2Pair(address _wbnbBusdV2Pair) external onlyOwner {
        WbnbBusdV2Pair = _wbnbBusdV2Pair;
    }

    function updateWbnbSpxV2Pair(address _wbnbSpxV2Pair) external onlyOwner {
        WbnbSpxV2Pair = _wbnbSpxV2Pair;
    }

    function updatePremiumToken(IERC20 _premiumToken) external onlyOwner {
        premiumToken = _premiumToken;
    }

    function updatePremiumPrice(uint256 _premiumPrice) external onlyOwner {
        premiumPrice = _premiumPrice;
    }

    function updatePremiumDuration(
        uint256 _premiumDuration
    ) external onlyOwner {
        premiumDuration = _premiumDuration;
    }

    function updateMiningPrice(uint256 _miningPrice) external onlyOwner {
        miningPrice = _miningPrice;
    }

    function updatePlantPrice(uint256 _plantPrice) external onlyOwner {
        plantPrice = _plantPrice;
    }

    function updateGoldPrice(uint256 _goldPrice) external onlyOwner {
        goldPrice = _goldPrice;
    }

    function updateUranPrice(uint256 _uranPrice) external onlyOwner {
        uranPrice = _uranPrice;
    }

    function updateLand1Price(uint256 _land1Price) external onlyOwner {
        land1Price = _land1Price;
    }

    function updateLand2Price(uint256 _land2Price) external onlyOwner {
        land2Price = _land2Price;
    }

    function updateLand3Price(uint256 _land3Price) external onlyOwner {
        land3Price = _land3Price;
    }

    function withdrawFundsByAdmin(
        IERC20 token,
        address to,
        uint256 amount
    ) external {
        require(msg.sender == fundsAdmin, "Invalid Admin");

        token.transfer(to, amount);
    }
}
