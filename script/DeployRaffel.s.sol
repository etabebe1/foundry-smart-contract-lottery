// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.24;
import {Script} from "forge-std/Script.sol";
import {console} from "forge-std/console.sol";
import {Raffel} from "../src/Raffel.sol";
import {HelperConfig} from "./HelperConfig.sol";

contract DeployRaffel is Script {
    function deployContract() public returns (Raffel, HelperConfig) {
        HelperConfig helperConfig = new HelperConfig();
        HelperConfig.NetworkConfig memory networkConfig = helperConfig
            .getNetworkConfig();

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

        // console.log("Raffel contract deployed at:", address(raffel));
        // console.log(
        //     "HelperConfig contract deployed at:",
        //     address(helperConfig)
        // );

        return (raffel, helperConfig);
    }

    function run() public {
        deployContract();
    }
}
