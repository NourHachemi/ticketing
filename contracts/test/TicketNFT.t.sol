// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {Test} from "forge-std/Test.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {TicketNFT} from "../src/TicketNFT.sol";

contract TicketNFTTest is Test {
    TicketNFT private ticket;

    address private seller = makeAddr("seller");
    address private buyer = makeAddr("buyer");
    address private secondBuyer = makeAddr("secondBuyer");

    uint256 private constant TICKET_PRICE = 0.01 ether;
    uint256 private constant MAX_SUPPLY = 2;
    string private constant METADATA_URI = "ipfs://metadata-cid";

    function setUp() public {
        ticket = new TicketNFT("Concert VIP", "VIP", TICKET_PRICE, MAX_SUPPLY, seller, METADATA_URI);
        vm.deal(buyer, 1 ether);
        vm.deal(secondBuyer, 1 ether);
    }

    function test_ConstructorSetsCategoryInformation() public view {
        assertEq(ticket.name(), "Concert VIP");
        assertEq(ticket.symbol(), "VIP");
        assertEq(ticket.ticketPrice(), TICKET_PRICE);
        assertEq(ticket.maxSupply(), MAX_SUPPLY);
        assertEq(ticket.owner(), seller);
        assertEq(ticket.remainingSupply(), MAX_SUPPLY);
    }

    function test_BuyTicketMintsNftAndKeepsPayment() public {
        vm.prank(buyer);
        uint256 tokenId = ticket.buyTicket{value: TICKET_PRICE}();

        assertEq(tokenId, 1);
        assertEq(ticket.ownerOf(tokenId), buyer);
        assertEq(ticket.totalMinted(), 1);
        assertEq(ticket.remainingSupply(), 1);
        assertEq(address(ticket).balance, TICKET_PRICE);
        assertEq(ticket.tokenURI(tokenId), METADATA_URI);
    }

    function test_BuyTicketRevertsWhenPaymentIsIncorrect() public {
        vm.prank(buyer);
        vm.expectRevert(abi.encodeWithSelector(TicketNFT.IncorrectPayment.selector, TICKET_PRICE, TICKET_PRICE - 1));
        ticket.buyTicket{value: TICKET_PRICE - 1}();
    }

    function test_MintForAllowsSellerToMintAfterEuroPayment() public {
        vm.prank(seller);
        uint256 tokenId = ticket.mintFor(buyer);

        assertEq(tokenId, 1);
        assertEq(ticket.ownerOf(tokenId), buyer);
        assertEq(address(ticket).balance, 0);
    }

    function test_MintForRevertsForNonSeller() public {
        vm.prank(buyer);
        vm.expectRevert(abi.encodeWithSelector(Ownable.OwnableUnauthorizedAccount.selector, buyer));
        ticket.mintFor(buyer);
    }

    function test_MintRevertsWhenTicketsAreSoldOut() public {
        vm.prank(buyer);
        ticket.buyTicket{value: TICKET_PRICE}();

        vm.prank(secondBuyer);
        ticket.buyTicket{value: TICKET_PRICE}();

        vm.prank(seller);
        vm.expectRevert(TicketNFT.SoldOut.selector);
        ticket.mintFor(seller);
    }

    function test_WithdrawTransfersAllFundsToSeller() public {
        vm.prank(buyer);
        ticket.buyTicket{value: TICKET_PRICE}();

        uint256 sellerBalanceBefore = seller.balance;

        vm.prank(seller);
        ticket.withdraw();

        assertEq(seller.balance, sellerBalanceBefore + TICKET_PRICE);
        assertEq(address(ticket).balance, 0);
    }

    function test_WithdrawRevertsForNonSeller() public {
        vm.prank(buyer);
        vm.expectRevert(abi.encodeWithSelector(Ownable.OwnableUnauthorizedAccount.selector, buyer));
        ticket.withdraw();
    }
}
