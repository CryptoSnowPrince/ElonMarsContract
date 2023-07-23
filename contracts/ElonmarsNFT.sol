// SPDX-License-Identifier: MIT

pragma solidity =0.8.17;

import "./@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
import "./@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "./@openzeppelin/contracts/access/Ownable.sol";

contract Elonmars is ERC1155, Ownable {
    mapping(uint256 => uint256) public price; // tokenID => price
    mapping(uint256 => uint256) public limit; // tokenID => limit

    // IERC20 public payToken = IERC20(0xe9e7CEA3DedcA5984780Bafc599bD69ADd087D56); // Bsc Mainnet
    // address public treasury = 0x2faf8ab2b9ac8Bd4176A0B9D31502bA3a59B4b41;
    // address public admin = 0x2faf8ab2b9ac8Bd4176A0B9D31502bA3a59B4b41;
    IERC20 public payToken = IERC20(0x7A62eE9B6cde5cdd3Fd9d82448952f8E2f99c8C0); // Bsc Testnet
    address public treasury = 0x2faf8ab2b9ac8Bd4176A0B9D31502bA3a59B4b41; // Test
    address public admin = 0x2faf8ab2b9ac8Bd4176A0B9D31502bA3a59B4b41; // Test

    mapping(uint256 => uint256) public totalSupply;

    constructor(string memory uri_) ERC1155(uri_) {
        price[0] = 30 ether;
        price[1] = 60 ether;
        price[2] = 90 ether;

        limit[0] = 45;
        limit[1] = 35;
        limit[2] = 20;
    }

    function mint(uint256 _quantity, uint256 _tokenID) external {
        require(_tokenID < 3, "Invalid Token ID");
        require(_quantity > 0, "Zero Amount");

        if (msg.sender != admin) {
            require(
                balanceOf(msg.sender, _tokenID) + _quantity <= limit[_tokenID],
                "Balance LIMIT"
            );

            uint256 amount = price[_tokenID] * _quantity;
            payToken.transferFrom(msg.sender, address(this), amount);
        }

        totalSupply[_tokenID] += _quantity;

        bytes memory data;
        _mint(msg.sender, _tokenID, _quantity, data);
    }

    function updatePrices(
        uint256 _common_price,
        uint256 _uncommon_price,
        uint256 _rare_price
    ) external onlyOwner {
        price[0] = _common_price;
        price[1] = _uncommon_price;
        price[2] = _rare_price;
    }
    
    function updateLimits(
        uint256 _common_limit,
        uint256 _uncommon_limit,
        uint256 _rare_limit
    ) external onlyOwner {
        limit[0] = _common_limit;
        limit[1] = _uncommon_limit;
        limit[2] = _rare_limit;
    }

    function updatePayToken(
        IERC20 _payToken
    ) external onlyOwner {
        payToken = _payToken;
    }

    function updateTreasury(
        address _treasury
    ) external onlyOwner {
        treasury = _treasury;
    }

    function updateAdmin(
        address _admin
    ) external onlyOwner {
        admin = _admin;
    }

    function withdraw(address to, uint256 amount) external {
        require(msg.sender == admin, "Invalid Admin");

        payToken.transfer(to, amount);
    }
}
