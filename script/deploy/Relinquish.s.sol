// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "forge-std/Script.sol";

import {ERC1967Proxy} from "@openzeppelin/contracts-v5/proxy/ERC1967/ERC1967Proxy.sol";
import {TransparentUpgradeableProxy} from "@openzeppelin/contracts-v4/proxy/transparent/TransparentUpgradeableProxy.sol";
import {IERC20} from "@openzeppelin/contracts-v4/token/ERC20/IERC20.sol";
import {IVotesUpgradeable} from "@openzeppelin/contracts-upgradeable-v4/governance/utils/IVotesUpgradeable.sol";
import {ProxyAdmin} from "@openzeppelin/contracts-v4/proxy/transparent/ProxyAdmin.sol";
import {TimelockController} from "@openzeppelin/contracts-v4/governance/TimelockController.sol";

import {ProposalTypesConfigurator} from "agora-governor/ProposalTypesConfigurator.sol";
import {AgoraGovernor} from "agora-governor/AgoraGovernor.sol";
import {IProposalTypesConfigurator} from "agora-governor/interfaces/IProposalTypesConfigurator.sol";
import {ApprovalVotingModule} from "agora-governor/modules/ApprovalVotingModule.sol";
import {OptimisticModule} from "agora-governor/modules/OptimisticModule.sol";

import {GovernanceToken} from "src/GovernanceToken.sol";

contract Relinquish is Script {
    ProxyAdmin proxyAdmin;
    ProposalTypesConfigurator proposalTypesConfigurator;
    TimelockController timelock;
    GovernanceToken govToken;
    AgoraGovernor governor;

    address governorAdmin;
    address governorManager;

    address constant public CHEEKY = 0x32B6d1CCbFB75aa0d52e036488b169597f0fE3d0;
    address constant public TOKEN = 0x949f5b6183aA74272Ddad7f8f8DC309F8186E858;
    address constant public GOV = 0x85d6BCC74877a1C6FC66a8cd14369f939663F68F;
    address constant public TIMELOCK = 0xAac9059248A06233DB16Fc9C25426365b7aFb481;
    address constant public PROXY_ADMIN = 0x42436bB7BEA1E1E2De03f1223e2A3e0557F606E3;

    constructor() {
    }

    function run() public {
        // Start broadcast.
        vm.startBroadcast();

        // Read caller information.
        (, address deployer,) = vm.readCallers();

        // Deploy membership
        govToken = GovernanceToken(TOKEN);
        governor = AgoraGovernor(payable(GOV));
        proxyAdmin = ProxyAdmin(PROXY_ADMIN);

        governor.setProposalThreshold(1);

        // Grant token roles
        govToken.grantRole(govToken.MINTER_ROLE(), CHEEKY);
        govToken.grantRole(govToken.BURNER_ROLE(), CHEEKY);
        govToken.grantRole(govToken.MINTER_ROLE(), TIMELOCK);
        govToken.grantRole(govToken.BURNER_ROLE(), TIMELOCK);
        govToken.revokeRole(govToken.MINTER_ROLE(), deployer);
        govToken.revokeRole(govToken.BURNER_ROLE(), deployer);

        // Transfer governor manager first, then admin (order matters!)
        governor.setManager(CHEEKY);
        governor.setAdmin(CHEEKY);

        // Transfer token admin to CHEEKY and revoke deployer
        govToken.grantRole(govToken.DEFAULT_ADMIN_ROLE(), CHEEKY);
        govToken.revokeRole(govToken.DEFAULT_ADMIN_ROLE(), deployer);

        // Transfer proxy admin control to Cheeky.
        proxyAdmin.transferOwnership(CHEEKY);

        vm.stopBroadcast();
    }

    // Exclude from coverage report
    function test() public virtual {}
}
