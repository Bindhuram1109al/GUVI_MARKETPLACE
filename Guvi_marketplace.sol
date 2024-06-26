// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/Pausable.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";

contract GUVIMarketplace is ERC721, Ownable, Pausable, ReentrancyGuard {
    using SafeMath for uint256;

    struct Item {
        uint256 id;
        address creator;
        uint256 price;
        bool isSold;
    }

    enum Role {USER, ADMIN}

    mapping(address => Role) private roles;
    mapping(uint256 => Item) public items;
    mapping(uint256 => address) public itemToOwner;

    event ItemListed(uint256 indexed itemId, uint256 price);
    event ItemSold(uint256 indexed itemId, address buyer, uint256 price);
    event NftWithdrawn(uint256 indexed itemId);

    modifier onlyRole(Role _role) {
        require(roles[msg.sender] == _role, "Access denied");
        _;
    }

    constructor() ERC721("GUVI Marketplace", "GUVI") {
        roles[msg.sender] = Role.ADMIN;
    }

    function setRole(address _user, Role _role) external onlyRole(Role.ADMIN) {
        roles[_user] = _role;
    }

    function listNewItem(uint256 _price) external onlyRole(Role.USER) whenNotPaused {
        uint256 itemId = totalSupply();
        _mint(msg.sender, itemId);
        items[itemId] = Item(itemId, msg.sender, _price, false);
        emit ItemListed(itemId, _price);
    }

    function buyItem(uint256 _itemId) external payable nonReentrant {
        require(_exists(_itemId), "Item does not exist");
        require(ownerOf(_itemId) != msg.sender, "You cannot buy your own item");
        require(items[_itemId].isSold == false, "Item has already been sold");
        require(msg.value >= items[_itemId].price, "Insufficient funds");

        address seller = ownerOf(_itemId);
        itemToOwner[_itemId] = msg.sender;
        items[_itemId].isSold = true;
        payable(seller).transfer(msg.value);
        _transfer(seller, msg.sender, _itemId);

        emit ItemSold(_itemId, msg.sender, items[_itemId].price);
    }

    function withdrawNft(uint256 _itemId) external onlyRole(Role.USER) {
        require(_exists(_itemId), "Item does not exist");
        require(ownerOf(_itemId) == msg.sender, "You do not own this item");
        require(items[_itemId].isSold == false, "Item has already been sold");

        _transfer(msg.sender, address(this), _itemId);
        emit NftWithdrawn(_itemId);
    }
}