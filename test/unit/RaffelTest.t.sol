// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.24;

import {Test} from "forge-std/Test.sol";
import {console} from "forge-std/console.sol";
import {DeployRaffel} from "../../script/DeployRaffel.s.sol";
import {HelperConfig} from "../../script/HelperConfig.sol";
import {Raffel} from "../../src/Raffel.sol";

contract RaffelTest is Test {
    Raffel public raffel;
    HelperConfig public helperConfig;

    address public PLAYER = makeAddr("player");
    uint256 public constant INITIAL_PLAYER_BALANCE = 10 ether;

    uint256 public entranceFee;
    uint256 public interval;
    address public vrfCoordinator;
    bytes32 public keyHash;
    uint256 public subscriptionId;
    uint32 public callbackGasLimit;

    function setUp() public {
        DeployRaffel deployRaffel = new DeployRaffel();

        (raffel, helperConfig) = deployRaffel.deployContract();

        HelperConfig.NetworkConfig memory networkConfig = helperConfig
            .getNetworkConfig();
        entranceFee = networkConfig.entranceFee;
        interval = networkConfig.interval;
        vrfCoordinator = networkConfig.vrfCoordinator;
        keyHash = networkConfig.keyHash;
        subscriptionId = networkConfig.subscriptionId;
        callbackGasLimit = networkConfig.callbackGasLimit;

        console.log(vrfCoordinator);
    }

    function test() public {
        console.log("test setup");
    }
}

//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//

// import {console} from "forge-std/console.sol";
// import {Test} from "forge-std/Test.sol";
// import {DeployRaffel} from "../../script/DeployRaffel.s.sol";
// import {Raffel} from "../../src/Raffel.sol";
// import {HelperConfig} from "../../script/HelperConfig.sol";

// contract RaffelTest is Test {
//     Raffel public raffel;
//     HelperConfig public helperConfig;

//     address public PLAYERS = makeAddr("player");
//     uint256 public STARTING_PLAYER_BALANCE = 10 ether;

//     uint256 public entranceFee;
//     uint256 public interval;
//     address public vrfCoordinator;
//     bytes32 public keyHash;
//     uint256 public subscriptionId;
//     uint32 public callbackGasLimit;

//     function setUp() public {
//         DeployRaffel deployer = new DeployRaffel();
//         (raffel, helperConfig) = deployer.deployContract();

//         HelperConfig.NetworkConfig memory networkConfig = helperConfig
//             .getConfig();

//         console.log(networkConfig.entranceFee);
//     }

//     function test() public {
//         console.log("hey");
//     }
// }
