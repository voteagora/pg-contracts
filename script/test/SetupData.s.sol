pragma solidity ^0.8.19;

import "forge-std/Script.sol";

import {Strings} from "@openzeppelin/contracts-v4/utils/Strings.sol";
import {ProposalTypesConfigurator} from "agora-governor/ProposalTypesConfigurator.sol";
import {AgoraGovernor} from "agora-governor/AgoraGovernor.sol";
import {IProposalTypesConfigurator} from "agora-governor/interfaces/IProposalTypesConfigurator.sol";
import {Membership} from "src/Membership.sol";

contract SetupData is Script {
    function run() external {
        Membership token = Membership(0x380afD534539ad1C43c3268E7Cb71BAa766aE6f9);
        AgoraGovernor governor = AgoraGovernor(payable(0x8fFF4C5ABcb31fAc43DcE92f77920F3cB9854fB8));
        ProposalTypesConfigurator proposalTypesConfigurator =
            ProposalTypesConfigurator(payable(0x966DAa9da3c7eF86c0F9fd678BD5D8cB1B856577));
        string memory env = "TEST_KEY_";

        uint256[] memory proposalIds = new uint256[](4);

        vm.startBroadcast();

        // On the first run:
        // Setup proposal types
        /*
        proposalTypesConfigurator.setProposalType(0, 0, 5_100, "Update Splits", "Lorem Ipsum", address(0));
        proposalTypesConfigurator.setProposalType(1, 0, 5_100, "DAO Membership", "Lorem Ipsum", address(0));
        proposalTypesConfigurator.setProposalType(2, 0, 5_000, "Distribute Splits", "Lorem Ipsum", address(0));
        proposalTypesConfigurator.setProposalType(3, 0, 5_100, "Signal Votes", "Lorem Ipsum", address(0));
        */

       governor.setManager(0x32B6d1CCbFB75aa0d52e036488b169597f0fE3d0);
       governor.setAdmin(0x32B6d1CCbFB75aa0d52e036488b169597f0fE3d0);
        /*
        for (uint256 i = 1; i < 31; i++) {
            (address user, uint256 userKey) = makeAddrAndKey(string.concat(env, Strings.toString(i)));
            console.log(user, i);

            address[] memory users = new address[](1);
            users[0] = user;

            token.mint(users);
            // Send ether to all wallets
            payable(user).transfer(0.0003 ether);

            address[] memory targets = new address[](1);
            targets[0] = user;

            uint256[] memory values = new uint256[](1);
            values[0] = i;

            bytes[] memory calldatas = new bytes[](1);
            calldatas[0] = "";

            uint256 id = governor.hashProposal(
                targets,
                values,
                calldatas,
                keccak256(bytes(string.concat("Initial proposal for the number ", Strings.toString(i))))
            );

            // Create proposals for each type
            if (i == 2) {
                vm.stopBroadcast();
                vm.startBroadcast(userKey);

                proposalIds[0] = id;

                governor.propose(
                    targets,
                    values,
                    calldatas,
                    string.concat("Initial proposal for the number ", Strings.toString(i)),
                    0
                );
                vm.stopBroadcast();
                vm.startBroadcast(vm.envUint("DEPLOYER_KEY"));
            }

            if (i == 3) {
                vm.stopBroadcast();
                vm.startBroadcast(userKey);

                proposalIds[1] = id;

                governor.propose(
                    targets,
                    values,
                    calldatas,
                    string.concat("Initial proposal for the number ", Strings.toString(i)),
                    1
                );
                vm.stopBroadcast();
                vm.startBroadcast(vm.envUint("DEPLOYER_KEY"));
            }

            if (i == 4) {
                vm.stopBroadcast();
                vm.startBroadcast(userKey);

                proposalIds[2] = id;

                governor.propose(
                    targets,
                    values,
                    calldatas,
                    string.concat("Initial proposal for the number ", Strings.toString(i)),
                    2
                );
                vm.stopBroadcast();
                vm.startBroadcast(vm.envUint("DEPLOYER_KEY"));
            }

            if (i == 5) {
                vm.stopBroadcast();
                vm.startBroadcast(userKey);

                proposalIds[3] = id;

                governor.propose(
                    targets,
                    values,
                    calldatas,
                    string.concat("Initial proposal for the number ", Strings.toString(i)),
                    3
                );
                vm.stopBroadcast();
                vm.startBroadcast(vm.envUint("DEPLOYER_KEY"));
            }
        }
        */

        vm.stopBroadcast();
    }

    // Exclude from coverage report
    function test() public {}
}
