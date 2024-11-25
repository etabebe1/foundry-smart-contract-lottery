// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.24;

import {Test} from "forge-std/Test.sol";
import {console} from "forge-std/console.sol";
import {DeployRaffel} from "../../script/DeployRaffel.s.sol";
import {HelperConfig} from "../../script/HelperConfig.s.sol";
import {Raffel} from "../../src/Raffel.sol";

abstract contract RaffelTestConstants {
    uint256 public constant INITIAL_PLAYER_BALANCE = 10 ether;
    uint256 public constant INITIAL_RAFFEL_STATUS = 0;
    uint256 public constant SEND_VALUE = 1e18;
}

contract RaffelTest is Test, RaffelTestConstants {
    Raffel public raffel;
    HelperConfig public helperConfig;

    address public PLAYER = makeAddr("player");

    uint256 public entranceFee;
    uint256 public interval;
    address public vrfCoordinator;
    bytes32 public keyHash;
    uint256 public subscriptionId;
    uint32 public callbackGasLimit;

    event RaffelEntered(address indexed player);
    event RaffelWinner(address indexed);

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
    }

    //** Enter Raffel test **//
    function testRaffelStatus() public view {
        assert(raffel.getRaffelStatus() == Raffel.RaffelStatus.OPEN);
    }

    function testPlayerHasEnoughEthToEnter() public {
        vm.startPrank(PLAYER);
        vm.deal(PLAYER, INITIAL_PLAYER_BALANCE);

        vm.expectRevert(Raffel.Raffel__SendMoreEth.selector);
        raffel.enterRaffel{value: 0}();
    }

    function testEnterRaffelRecordsPlayer() public {
        vm.startPrank(PLAYER);
        vm.deal(PLAYER, INITIAL_PLAYER_BALANCE);

        raffel.enterRaffel{value: SEND_VALUE}();
        assert(raffel.getPlayers(0) == PLAYER);
    }

    function testEmitEventWhenEnterRaffel() public {
        vm.startPrank(PLAYER);
        vm.deal(PLAYER, INITIAL_PLAYER_BALANCE);

        vm.expectEmit(true, false, false, false, address(raffel));
        emit RaffelEntered(PLAYER);

        raffel.enterRaffel{value: SEND_VALUE}();
    }

    function testEnterRaffelNotAllowedWhileCalculating() public {
        vm.startPrank(PLAYER);
        vm.deal(PLAYER, INITIAL_PLAYER_BALANCE);
        raffel.enterRaffel{value: SEND_VALUE}();

        vm.warp(block.timestamp + interval + 1);
        vm.roll(block.number + 1);

        raffel.performUpkeep("");

        vm.expectRevert(Raffel.Raffel_RaffelNotOpen.selector);
        raffel.enterRaffel{value: SEND_VALUE}();
    }

    //** Check UPkeep Test **//
    // function testEnoughTimeHasPassedForUpkeep() public {

    // }

    function testCheckUpkeepTimeHasPassed() public {
        vm.warp(block.timestamp + interval + 1);
        vm.roll(block.number + 1);

        (bool upkeepNeeded, ) = raffel.checkUpkeep("");

        console.log(upkeepNeeded);
        assert(upkeepNeeded == false);
    }

    function testCheckUpkeepRaffelIsOpen() public {}

    function testCheckUpkeepRaffelHasEth() public {}
}
