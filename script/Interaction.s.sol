// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.26;

import {Script, console} from "forge-std/Script.sol";
import {HelperConfig} from "./HelperConfig.sol";
import {Raffel} from "../src/Raffel.sol";
import {VRFCoordinatorV2_5Mock} from "@chainlink/contracts/v0.8/vrf/mocks/VRFCoordinatorV2_5Mock.sol";

contract CreateSubscription is Script {
    function createSubscriptionUsingConfig()
        internal
        returns (uint256, address)
    {
        HelperConfig helperConfig = new HelperConfig();
        address vfrCoordinator = helperConfig.getNetworkConfig().vrfCoordinator;

        (uint256 subscriptionId, address _vrfCoordinator) = createSubscription(
            vfrCoordinator
        );

        console.log(subscriptionId, _vrfCoordinator);
    }

    function createSubscription(
        address _vfrCoordinator
    ) public returns (uint256, address) {
        // console.log(_vfrCoordinator);
        vm.startBroadcast();
        uint256 subscriptionId = VRFCoordinatorV2_5Mock(_vfrCoordinator)
            .createSubscription();
        vm.stopBroadcast();
        return (subscriptionId, _vfrCoordinator);
    }

    function run() public {
        createSubscriptionUsingConfig();
    }
}
