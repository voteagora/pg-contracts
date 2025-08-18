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

        vm.startBroadcast(); // must be the admin EOA here

        // Deploy new implementation
        GovernanceToken newImplementation = new GovernanceToken();

        // Call upgradeTo directly on the proxy
        ITransparentUpgradeableProxy(proxyAddress).upgradeTo(address(newImplementation));

        vm.stopBroadcast();
    }
}
