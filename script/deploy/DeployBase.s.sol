// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "forge-std/Script.sol";

import {TransparentUpgradeableProxy} from "@openzeppelin/contracts-v4/proxy/transparent/TransparentUpgradeableProxy.sol";
import {IERC20} from "@openzeppelin/contracts-v4/token/ERC20/IERC20.sol";
import {IVotesUpgradeable} from "@openzeppelin/contracts-upgradeable-v4/governance/utils/IVotesUpgradeable.sol";

import {ProposalTypesConfigurator} from "agora-governor/ProposalTypesConfigurator.sol";
import {AgoraGovernor} from "agora-governor/AgoraGovernor.sol";
import {IProposalTypesConfigurator} from "agora-governor/interfaces/IProposalTypesConfigurator.sol";

import {Timelock} from "src/Timelock.sol";
import {ProxyAdmin} from "src/ProxyAdmin.sol";

abstract contract DeployBase is Script {
    ProxyAdmin proxyAdmin;
    ProposalTypesConfigurator proposalTypesConfigurator;
    Timelock timelock;
    IERC20 token;

    constructor(address _token) {
        token = IERC20(_token);
    }

    function setup() internal {
        // Start broadcast.
        vm.startBroadcast();

        // Read caller information.
        (, address deployer,) = vm.readCallers();

        // Proposal types for governor.
        IProposalTypesConfigurator.ProposalType[] memory proposalTypes =
            new IProposalTypesConfigurator.ProposalType[](4);

        // Deploy implementations.
        {
            address[] memory owners = new address[](1);
            owners[0] = deployer;

            // Non-proxy implementations
            proxyAdmin = new ProxyAdmin(owners);
        }
        proposalTypesConfigurator = new ProposalTypesConfigurator();

        // Proxy implementations
        AgoraGovernor governorImplementation = new AgoraGovernor();
        Timelock timelockImplementation = new Timelock();

        // Deploy proxies.
        timelock = Timelock(
            payable(
                address(
                    new TransparentUpgradeableProxy{salt: keccak256("TimelockCyber")}(
                        address(timelockImplementation), address(proxyAdmin), ""
                    )
                )
            )
        );

        address governor = address(
            new TransparentUpgradeableProxy{salt: keccak256("AgoraGovernorCyber")}(
                address(governorImplementation),
                address(proxyAdmin),
                abi.encodeWithSelector(
                    AgoraGovernor.initialize.selector,
                    token,
                    deployer,
                    deployer,
                    timelock,
                    proposalTypesConfigurator,
                    proposalTypes
                )
            )
        );

        timelock.initialize(0, governor, deployer);

        vm.stopBroadcast();
    }

    // Exclude from coverage report
    function test() public virtual {}
}
