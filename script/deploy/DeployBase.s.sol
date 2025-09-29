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

    address constant public CHEEKY = 0x32B6d1CCbFB75aa0d52e036488b169597f0fE3d0;

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

        // Deploy module
        // ApprovalVotingModule approvalVoting = new ApprovalVotingModule(governor);
        // AgoraGovernor(payable(governor)).setModuleApproval(address(approvalVoting), true);

        // Deploy module
        // OptimisticModule optimistic = new OptimisticModule(address(governor));
        // AgoraGovernor(payable(governor)).setModuleApproval(address(optimistic), true);

        // On the first run:
        // Setup proposal types
        // proposalTypesConfigurator.setProposalType(0, 0, 0, "Signal Votes", "Simple Majority", address(optimistic));

        proposalTypesConfigurator.setProposalType(
            0, 3_300, 5_100, "Requires Quorum", "Admin the DAO, Modify Splits", address(0)
        );
        proposalTypesConfigurator.setProposalType(
            1, 0, 10_000, "No Quorum", "Distribute Splits", address(0)
        );

        // Grant token roles
        govToken.grantRole(govToken.MINTER_ROLE(), CHEEKY);
        govToken.grantRole(govToken.BURNER_ROLE(), CHEEKY);
        govToken.grantRole(govToken.MINTER_ROLE(), address(timelock));
        govToken.grantRole(govToken.BURNER_ROLE(), address(timelock));

        // Transfer governor manager first, then admin (order matters!)
        AgoraGovernor(payable(governor)).setManager(CHEEKY);
        AgoraGovernor(payable(governor)).setAdmin(CHEEKY);

        // Transfer token admin to CHEEKY and revoke deployer
        govToken.grantRole(govToken.DEFAULT_ADMIN_ROLE(), CHEEKY);
        govToken.revokeRole(govToken.DEFAULT_ADMIN_ROLE(), deployer);

        // Change the admin of the governor proxy to CHEEKY
        proxyAdmin.changeProxyAdmin(TransparentUpgradeableProxy(payable(governor)), CHEEKY);

        // Transfer proxy admin control to Cheeky.
        proxyAdmin.transferOwnership(CHEEKY);

        vm.stopBroadcast();
    }

    // Exclude from coverage report
    function test() public virtual {}
}
