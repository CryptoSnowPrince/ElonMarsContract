// SPDX-License-Identifier: MIT

pragma solidity =0.8.17;

import "./@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
import "./@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "./@openzeppelin/contracts/access/Ownable.sol";
import "./@openzeppelin/contracts/utils/Strings.sol";

contract ElonmarsNFT is ERC1155, Ownable {
    using Strings for uint256;

    mapping(uint256 => uint256) public price; // tokenID => price

    IERC20 public payToken = IERC20(0xe9e7CEA3DedcA5984780Bafc599bD69ADd087D56);
    address public mintAdmin = 0x8e946b7453320383df75f080F7DA843c043DfB47; // CONFIG
    address public withdrawAdmin = 0x2faf8ab2b9ac8Bd4176A0B9D31502bA3a59B4b41; // CONFIG

    mapping(uint256 => uint256) public totalSupply;

    constructor(string memory uri_) ERC1155(uri_) {
        price[0] = 30 ether;
        price[1] = 60 ether;
        price[2] = 90 ether;
    }

    function mint(uint256 _quantity, uint256 _tokenID) external {
        require(_tokenID < 3, "Invalid Token ID");
        require(_quantity > 0, "Zero Amount");

        if (msg.sender != mintAdmin) {
            uint256 amount = price[_tokenID] * _quantity;
            payToken.transferFrom(msg.sender, address(this), amount);
        }

        totalSupply[_tokenID] += _quantity;

        bytes memory data;
        _mint(msg.sender, _tokenID, _quantity, data);
    }

    function uri(
        uint256 _tokenID
    ) public view override returns (string memory) {
        return
            bytes(_uri).length > 0
                ? string(abi.encodePacked(_uri, _tokenID.toString(), ".json"))
                : "";
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

    function updatePayToken(IERC20 _payToken) external onlyOwner {
        payToken = _payToken;
    }

    function updateMintAdmin(address _mintAdmin) external onlyOwner {
        mintAdmin = _mintAdmin;
    }

    function updateWithdrawAdmin(address _withdrawAdmin) external onlyOwner {
        withdrawAdmin = _withdrawAdmin;
    }

    function withdraw(address to, uint256 amount) external {
        require(msg.sender == withdrawAdmin, "Invalid Withdraw Admin");

        payToken.transfer(to, amount);
    }
}
