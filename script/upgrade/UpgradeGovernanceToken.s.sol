// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "forge-std/Script.sol";
import {GovernanceToken} from "src/GovernanceToken.sol";
import {UUPSUpgradeable} from "@openzeppelin/contracts-upgradeable-v5/proxy/utils/UUPSUpgradeable.sol";

contract UpgradeGovernanceToken is Script {
    function run() external {
        // Address of the deployed proxy (Sepolia testnet)
        address proxyAddress = 0xE3D4a55f780C5aD9B3009523CB6a3d900A8FA723;
        
        vm.startBroadcast();
        
        // Deploy new implementation
        GovernanceToken newImplementation = new GovernanceToken();
        
        // Call upgradeToAndCall through the UUPSUpgradeable interface
        UUPSUpgradeable(proxyAddress).upgradeToAndCall(
            address(newImplementation),
            bytes("") // Empty bytes for no initialization
        );
        
        vm.stopBroadcast();
    }
}