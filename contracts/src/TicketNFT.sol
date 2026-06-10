// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {ERC721} from "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";

contract TicketNFT is ERC721, Ownable {
    uint256 public immutable ticketPrice;
    uint256 public immutable maxSupply;
    uint256 public totalMinted;
    string private _metadataURI;

    error IncorrectPayment(uint256 expected, uint256 received);
    error SoldOut();
    error InvalidBuyer();
    error NoFundsToWithdraw();
    error EtherTransferFailed();

    event TicketPurchased(address indexed buyer, uint256 indexed tokenId, uint256 price);
    event TicketMintedFor(address indexed buyer, uint256 indexed tokenId);
    event FundsWithdrawn(address indexed seller, uint256 amount);

    constructor(
        string memory name,
        string memory symbol,
        uint256 price,
        uint256 supply,
        address seller,
        string memory metadataURI
    ) ERC721(name, symbol) Ownable(seller) {
        ticketPrice = price;
        maxSupply = supply;
        _metadataURI = metadataURI;
    }

    function buyTicket() external payable returns (uint256 tokenId) {
        if (msg.value != ticketPrice) {
            revert IncorrectPayment(ticketPrice, msg.value);
        }

        tokenId = _mintTicket(msg.sender);
        emit TicketPurchased(msg.sender, tokenId, msg.value);
    }

    function mintFor(address buyer) external onlyOwner returns (uint256 tokenId) {
        if (buyer == address(0)) {
            revert InvalidBuyer();
        }

        tokenId = _mintTicket(buyer);
        emit TicketMintedFor(buyer, tokenId);
    }

    function withdraw() external onlyOwner {
        uint256 amount = address(this).balance;
        if (amount == 0) {
            revert NoFundsToWithdraw();
        }

        (bool success,) = payable(owner()).call{value: amount}("");
        if (!success) {
            revert EtherTransferFailed();
        }

        emit FundsWithdrawn(owner(), amount);
    }

    function remainingSupply() external view returns (uint256) {
        return maxSupply - totalMinted;
    }

    function tokenURI(uint256 tokenId) public view override returns (string memory) {
        _requireOwned(tokenId);
        return _metadataURI;
    }

    function _mintTicket(address buyer) internal returns (uint256 tokenId) {
        if (totalMinted >= maxSupply) {
            revert SoldOut();
        }

        tokenId = totalMinted + 1;
        totalMinted = tokenId;
        _safeMint(buyer, tokenId);
    }
}
