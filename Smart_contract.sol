pragma solidity ^0.8.0;

import "https://github.com/OpenZeppelin/openzeppelin-solidity/contracts/token/ERC721/SafeERC721.sol";

contract NFTMarketplace {
    address private owner;
    mapping (address => uint256) public balances;

    constructor() public {
        owner = msg.sender;
    }

    function createNFT(string memory _name, string memory _description, uint256 _price) public {
        // Create a new NFT and store it in the contract
    }

    function buyNFT(uint256 _nftId) public payable {
        // Buy an NFT and transfer ownership
    }

    function sellNFT(uint256 _nftId, uint256 _price) public {
        // Sell an NFT and transfer ownership
    }
}