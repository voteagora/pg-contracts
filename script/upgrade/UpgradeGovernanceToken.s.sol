// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "forge-std/Script.sol";
import {GovernanceToken} from "src/GovernanceToken.sol";

// This is the TransparentUpgradeableProxy itself
interface ITransparentUpgradeableProxy {
    function upgradeTo(address newImplementation) external;
}

contract UpgradeGovernanceToken is Script {
    function run() external {
        // Proxy address (the one users interact with)
        address proxyAddress = 0xE3D4a55f780C5aD9B3009523CB6a3d900A8FA723;
        //address proxyAddress = 0x309E4466149d2E6286978680f4f9e2726A999E43;

        vm.startBroadcast(); // must be the admin EOA here

        // Deploy new implementation
        GovernanceToken newImplementation = new GovernanceToken();

        GovernanceToken(proxyAddress).upgradeToAndCall(address(newImplementation), bytes(""));

        // Call upgradeTo directly on the proxy
        // GovernanceToken(proxyAddress).upgradeToAndCall(address(newImplementation), abi.encodeWithSelector(GovernanceToken.initialize.selector,
        //                0xA622279f76ddbed4f2CC986c09244262Dba8f4Ba,
        //                0xF5B87BD1206d7658C344Fe1CB56D9498B4286A67,
        //                "ProtocolGuild",
        //                "PGUILD"));

        vm.stopBroadcast();
    }
}