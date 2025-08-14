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

abstract contract DeployBase is Script {
    ProxyAdmin proxyAdmin;
    ProposalTypesConfigurator proposalTypesConfigurator;
    TimelockController timelock;
    GovernanceToken govToken;

    address governorAdmin;
    address governorManager;

    constructor(address _governorAdmin, address _governorManager) {
        governorAdmin = _governorAdmin;
        governorManager = _governorManager;
    }

    function setup() internal {
        // Start broadcast.
        vm.startBroadcast();

        // Read caller information.
        (, address deployer,) = vm.readCallers();

        // Proposal types for governor.
        ProposalTypesConfigurator.ProposalType[] memory proposalTypes = new ProposalTypesConfigurator.ProposalType[](0);

        proxyAdmin = new ProxyAdmin();

        // Governor
        AgoraGovernor governorImplementation = new AgoraGovernor();

        address proposalTypesAddress = vm.computeCreateAddress(deployer, vm.getNonce(deployer) + 3);
        address timelockAddress = vm.computeCreateAddress(deployer, vm.getNonce(deployer) + 4);

        // Deploy membership
        govToken = GovernanceToken(
            address(
                new ERC1967Proxy{salt: keccak256(abi.encodePacked("PGGovToken"))}(
                    address(new GovernanceToken{salt: keccak256(abi.encodePacked("PGGovTokenImplementation"))}()),
                    abi.encodeWithSignature(
                        "initialize(address,address,string,string)",
                        deployer,
                        timelockAddress,
                        "ProtocolGuild",
                        "PGUILD"
                    )
                )
            )
        );

        address governor = address(
            new TransparentUpgradeableProxy{salt: keccak256("AgoraGovernorPG1")}(
                address(governorImplementation),
                address(proxyAdmin),
                abi.encodeWithSelector(
                    AgoraGovernor.initialize.selector,
                    govToken,
                    AgoraGovernor.SupplyType.Total,
                    governorAdmin,
                    governorManager,
                    timelockAddress,
                    proposalTypesAddress,
                    proposalTypes
                )
            )
        );

        // Proposal Types Configurator
        proposalTypesConfigurator = new ProposalTypesConfigurator(address(governor), proposalTypes);
        assert(address(proposalTypesConfigurator) == proposalTypesAddress);

        // Timelock
        address[] memory governorProxy = new address[](1);
        governorProxy[0] = governor;
        timelock = new TimelockController(1 days, governorProxy, governorProxy, deployer);
        // proxyAdmin.transferOwnership(address(timelock));
        assert(address(timelock) == timelockAddress);

        // Govenor modules
        // ApprovalVotingModule approvalVoting = new ApprovalVotingModule(governor);
        // AgoraGovernor(payable(governor)).setModuleApproval(address(approvalVoting), true);

        // Deploy module
        OptimisticModule optimistic = new OptimisticModule(address(governor));
        AgoraGovernor(payable(governor)).setModuleApproval(address(optimistic), true);

        // On the first run:
        // Setup proposal types
        proposalTypesConfigurator.setProposalType(0, 0, 0, "Signal Votes", "Simple Majority", address(optimistic));

        proposalTypesConfigurator.setProposalType(
            1, 0, 5_100, "Distribute Splits", "Set splits distribution", address(0)
        );
        proposalTypesConfigurator.setProposalType(
            2, 3_300, 5_100, "Update Splits", "All other split contract calls", address(0)
        );

        vm.stopBroadcast();
    }

    // Exclude from coverage report
    function test() public virtual {}
}
