// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.24;

import {Script} from "forge-std/Script.sol";
import {console} from "forge-std/console.sol";
import {Raffel} from "../src/Raffel.sol";
import {HelperConfig} from "./HelperConfig.s.sol";
import {CreateSubscription, FundSubscription, AddConsumer} from "./Interaction.s.sol";

contract DeployRaffel is Script {
    function deployContract() public returns (Raffel, HelperConfig) {
        HelperConfig helperConfig = new HelperConfig();
        HelperConfig.NetworkConfig memory networkConfig = helperConfig
            .getNetworkConfig();

        if (networkConfig.subscriptionId == 0) {
            // create subscription
            CreateSubscription createSubscription = new CreateSubscription();
            (uint256 subscriptionId, ) = createSubscription.createSubscription(
                networkConfig.vrfCoordinator
            );
            // (uint256 subscriptionId, ) = createSubscription.createSubscriptionUsingConfig();//Default subscriptionId creator;

            networkConfig.subscriptionId = subscriptionId;

            // Fund subscription
            FundSubscription fundSubscription = new FundSubscription();
            fundSubscription.fundSubscription(
                networkConfig.vrfCoordinator,
                networkConfig.subscriptionId,
                networkConfig.linkToken
            );
        }
        vm.startBroadcast();
        // console.log("subId from netConfig:", networkConfig.subscriptionId);
        Raffel raffel = new Raffel(
            networkConfig.entranceFee,
            networkConfig.interval,
            networkConfig.vrfCoordinator,
            networkConfig.keyHash,
            networkConfig.subscriptionId,
            networkConfig.callbackGasLimit
        );
        vm.stopBroadcast();

        AddConsumer addConsumer = new AddConsumer();
        addConsumer.addConsumer(
            address(raffel),
            networkConfig.subscriptionId,
            networkConfig.vrfCoordinator
        );

        return (raffel, helperConfig);
    }

    function run() public {
        deployContract();
    }
}
