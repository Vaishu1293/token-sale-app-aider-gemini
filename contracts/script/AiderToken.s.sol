// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Script, console} from "forge-std/Script.sol";
import {AiderToken} from "../src/AiderToken.sol";

contract DeployAiderToken is Script {
    AiderToken public aiderToken;

    function run() public returns (AiderToken) {
        vm.startBroadcast();
        // The deployer (msg.sender via vm.startBroadcast) will be the initial owner
        aiderToken = new AiderToken(msg.sender);
        vm.stopBroadcast();
        return aiderToken;
    }
}
