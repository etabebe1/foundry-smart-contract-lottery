// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.26;

import {Script, console} from "forge-std/Script.sol";
import {HelperConfig, HelperConfigConstants} from "./HelperConfig.s.sol";
import {Raffel} from "../src/Raffel.sol";
import {VRFCoordinatorV2_5Mock} from "../lib/chainlink-brownie-contracts/contracts/src/v0.8/vrf/mocks/VRFCoordinatorV2_5Mock.sol";

import {LinkToken} from "../test/mocks/LinkToken.sol";
import {DevOpsTools} from "../lib/foundry-devops/src/DevOpsTools.sol";

contract CreateSubscription is Script {
    function createSubscriptionUsingConfig() public returns (uint256, address) {
        HelperConfig helperConfig = new HelperConfig();
        address vfrCoordinator = helperConfig.getNetworkConfig().vrfCoordinator;

        (uint256 subscriptionId, address _vrfCoordinator) = createSubscription(
            vfrCoordinator
        );

        // console.log(subscriptionId, _vrfCoordinator);
        return (subscriptionId, _vrfCoordinator);
    }

    function createSubscription(
        address _vfrCoordinator
    ) public returns (uint256, address) {
        // console.log(_vfrCoordinator);
        vm.startBroadcast();
        uint256 subscriptionId = VRFCoordinatorV2_5Mock(_vfrCoordinator)
            .createSubscription();
        vm.stopBroadcast();

        // console.log("subId:", subscriptionId);
        return (subscriptionId, _vfrCoordinator);
    }

    function run() public {
        createSubscriptionUsingConfig();
    }
}

contract FundSubscription is Script, HelperConfigConstants {
    uint256 public constant FUND_AMOUNT = 3 ether;

    function fundSubscriptionUsingConfig() internal {
        HelperConfig helperConfig = new HelperConfig();
        address vrfCoordinator = helperConfig.getNetworkConfig().vrfCoordinator;
        uint256 subscriptionId = helperConfig.getNetworkConfig().subscriptionId;
        address linkToken = helperConfig.getNetworkConfig().linkToken;

        fundSubscription(vrfCoordinator, subscriptionId, linkToken);
    }

    function fundSubscription(
        address vrfCoordinator,
        uint256 subscriptionId,
        address linkToken
    ) public {
        // console.log("VRF Coordinator:", vrfCoordinator);
        // console.log("Subscription ID:", subscriptionId);
        // console.log("LINK Token:", linkToken);
        // console.log("Chain ID:", block.chainid);

        if (block.chainid == ETH_ANVIL_CHAIN_ID) {
            vm.startBroadcast();
            VRFCoordinatorV2_5Mock(vrfCoordinator).fundSubscription(
                subscriptionId,
                FUND_AMOUNT
            );
            vm.stopBroadcast();
        } else {
            vm.startBroadcast();
            // console.log(msg.sender);
            // console.log(
            //     "LINK Balance:",
            //     LinkToken(linkToken).balanceOf(msg.sender)
            // );

            LinkToken(linkToken).transferAndCall(
                vrfCoordinator,
                FUND_AMOUNT,
                abi.encode(subscriptionId)
            );
            vm.stopBroadcast();
        }
    }

    function run() public {
        fundSubscriptionUsingConfig();
    }
}

contract AddConsumer is Script, HelperConfigConstants {
    function addConsumerUsingConfig(address mostRecentDeployed) public {
        HelperConfig helperConfig = new HelperConfig();
        address vrfCoordinator = helperConfig.getNetworkConfig().vrfCoordinator;
        uint256 subscriptionId = helperConfig.getNetworkConfig().subscriptionId;

        addConsumer(mostRecentDeployed, subscriptionId, vrfCoordinator);
    }

    function addConsumer(
        address mostRecentDeployed,
        uint256 subscriptionId,
        address vrfCoordinator
    ) public {
        // console.log("Adding consumer contract:", mostRecentDeployed);
        // console.log("To VRFCoordinator:", vrfCoordinator);
        // console.log("With Subscription ID:", subscriptionId);
        // console.log("On chain:", block.chainid);

        vm.startBroadcast();
        /**
         *  @dev addConsumer function is coming from
         * SubscriptionAPI
         */
        VRFCoordinatorV2_5Mock(vrfCoordinator).addConsumer(
            subscriptionId,
            mostRecentDeployed
        );
        vm.stopBroadcast();
    }

    function run() public {
        address mostRecentlyDeployed = DevOpsTools.get_most_recent_deployment(
            "Raffel",
            block.chainid
        );
        addConsumerUsingConfig(mostRecentlyDeployed);
    }
}
