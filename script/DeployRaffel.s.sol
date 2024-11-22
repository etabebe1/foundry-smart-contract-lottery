// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.24;

import {Script} from "forge-std/Script.sol";
import {console} from "forge-std/console.sol";
import {Raffel} from "../src/Raffel.sol";
import {HelperConfig} from "./HelperConfig.s.sol";
import {CreateSubscription} from "./Interaction.s.sol";

contract DeployRaffel is Script {
    function deployContract() public returns (Raffel, HelperConfig) {
        HelperConfig helperConfig = new HelperConfig();
        HelperConfig.NetworkConfig memory networkConfig = helperConfig
            .getNetworkConfig();

        if (networkConfig.subscriptionId == 0) {
            CreateSubscription createSubscription = new CreateSubscription();

            (uint256 subscriptionId, ) = createSubscription.createSubscription(
                networkConfig.vrfCoordinator
            );
            // createSubscription.createSubscriptionUsingConfig();//Default subscriptionId creator;

            // console.log("Subscription id: ", subscriptionId);
        }

        // 83221883169009621906046539587471480394795988389900025103665964919962906628290x779877A7B0D9E8603169DdbD7836e478b4624789

        vm.startBroadcast();

        Raffel raffel = new Raffel(
            networkConfig.entranceFee,
            networkConfig.interval,
            networkConfig.vrfCoordinator,
            networkConfig.keyHash,
            networkConfig.subscriptionId,
            networkConfig.callbackGasLimit
        );

        vm.stopBroadcast();
        return (raffel, helperConfig);
    }

    function run() public {
        deployContract();
    }
}
