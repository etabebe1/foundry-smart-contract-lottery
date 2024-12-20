// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.24;

import {Script, console} from "forge-std/Script.sol";
// import {VRFCoordinatorV2_5Mock} from "@chainlink/contracts/v0.8/vrf/mocks/VRFCoordinatorV2_5Mock.sol";
import {VRFCoordinatorV2_5Mock} from "../lib/chainlink-brownie-contracts/contracts/src/v0.8/vrf/mocks/VRFCoordinatorV2_5Mock.sol";
import {LinkToken} from "../test/mocks/LinkToken.sol";

abstract contract HelperConfigConstants {
    uint256 ETH_MAINNET_CHAIN_ID = 1;
    uint256 ETH_SEPOLIA_CHAIN_ID = 11155111;
    uint256 ETH_ANVIL_CHAIN_ID = 31337;

    /* VRF Mock values*/
    uint96 baseFee = 0.25 ether;
    uint96 gasPrice = 1e9;
    int256 weiPerUintLink = 1e18;
}

contract HelperConfig is Script, HelperConfigConstants {
    error HelperConfig__InvalidChainId();

    struct NetworkConfig {
        uint256 entranceFee;
        uint256 interval;
        address vrfCoordinator;
        bytes32 keyHash;
        uint256 subscriptionId;
        uint32 callbackGasLimit;
        address linkToken;
    }

    NetworkConfig public activeNetworkConfig;
    mapping(uint256 chainId => NetworkConfig) networkConfigs;

    constructor() {
        initializeNetworkConfig();
        handleAnvilMock();
        setActiveNetworkConfig();
    }

    function initializeNetworkConfig() internal {
        // Mainnet NetworkConfig
        networkConfigs[ETH_MAINNET_CHAIN_ID] = NetworkConfig({
            entranceFee: 0.01 ether,
            interval: 30,
            vrfCoordinator: 0xD7f86b4b8Cae7D942340FF628F82735b7a20893a,
            keyHash: 0x3fd2fec10d06ee8f65e7f2e95f5c56511359ece3f33960ad8a866ae24a8ff10b,
            subscriptionId: 0,
            callbackGasLimit: 50000,
            linkToken: 0x514910771AF9Ca656af840dff83E8264EcF986CA
        });

        // Sepolia NetworkConfig
        networkConfigs[ETH_SEPOLIA_CHAIN_ID] = NetworkConfig({
            entranceFee: 0.01 ether,
            interval: 30,
            vrfCoordinator: 0x9DdfaCa8183c41ad55329BdeeD9F6A8d53168B1B,
            keyHash: 0x787d74caea10b2b357790d5b5247c2f63d1d91572a9846f780606e4d953677ae,
            subscriptionId: 58322188316900962190604653958747148039479598838990002510366596491996290662829,
            callbackGasLimit: 50000,
            linkToken: 0x779877A7B0D9E8603169DdbD7836e478b4624789
        });

        //Anvil NetworkConfig
        networkConfigs[ETH_ANVIL_CHAIN_ID] = NetworkConfig({
            entranceFee: 0.01 ether,
            interval: 30,
            vrfCoordinator: address(0),
            keyHash: bytes32(0),
            subscriptionId: 0, //FIXME: SubId should be fixed form chain link SubId-->Fixed see Interaction.s.sol && DeployRaffel.s.sol
            callbackGasLimit: 50000,
            linkToken: address(0)
        });
    }

    function setActiveNetworkConfig() internal returns (NetworkConfig memory) {
        uint256 currentChainId = block.chainid;

        if (networkConfigs[currentChainId].vrfCoordinator != address(0)) {
            activeNetworkConfig = networkConfigs[currentChainId];

            return activeNetworkConfig;
        } else {
            revert HelperConfig__InvalidChainId();
        }
    }

    function handleAnvilMock() internal {
        VRFCoordinatorV2_5Mock vrfCoordinatorMockAddr = new VRFCoordinatorV2_5Mock(
                baseFee,
                gasPrice,
                weiPerUintLink
            );

        networkConfigs[ETH_ANVIL_CHAIN_ID].vrfCoordinator = address(
            vrfCoordinatorMockAddr
        );

        LinkToken linkTokenMock = new LinkToken();
        networkConfigs[ETH_ANVIL_CHAIN_ID].linkToken = address(linkTokenMock);

        vm.startBroadcast();
        uint256 subscriptionId = vrfCoordinatorMockAddr.createSubscription();
        vm.stopBroadcast();
        networkConfigs[ETH_ANVIL_CHAIN_ID].subscriptionId = subscriptionId;
    }

    //* getter function */
    function getNetworkConfig() external view returns (NetworkConfig memory) {
        return networkConfigs[block.chainid];
    }
}
