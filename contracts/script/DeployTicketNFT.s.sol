// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {Script, console} from "forge-std/Script.sol";
import {TicketNFT} from "../src/TicketNFT.sol";

contract DeployTicketNFT is Script {
    function run() external returns (TicketNFT ticket) {
        address seller = vm.envAddress("SELLER_ADDRESS");

        vm.startBroadcast();
        ticket = new TicketNFT("Concert VIP", "VIP", 0.01 ether, 100, seller, "ipfs://replace-with-metadata-cid");
        vm.stopBroadcast();

        console.log("TicketNFT deployed at:", address(ticket));
        console.log("Seller:", seller);
    }
}
