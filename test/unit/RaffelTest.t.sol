// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.24;

import {Test} from "forge-std/Test.sol";
import {console} from "forge-std/console.sol";
import {DeployRaffel} from "../../script/DeployRaffel.s.sol";
import {HelperConfig} from "../../script/HelperConfig.sol";
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

    function testRaffelStatus() public view {
        assert(raffel.getRaffelStatus() == Raffel.RaffelStatus.OPEN);
    }

    function testIfPlayerHasNoEnoughEth() public payable {
        vm.startPrank(PLAYER);
        vm.expectRevert(Raffel.Raffel__SendMoreEth.selector);
        raffel.enterRaffel(); //* test passes because sending empty or 0 Eth value makes enterRaffel() to fails or revert
        // raffel.enterRaffel{value: 10 ether}(); //* test fails because sending eth > entranceFee transaction do not fail
    }

    function testRaffelRecordsPlayerAsTheyEnter() public payable {
        vm.startPrank(PLAYER);
        vm.deal(PLAYER, INITIAL_PLAYER_BALANCE);
        raffel.enterRaffel{value: SEND_VALUE}();
        assert(raffel.getPlayers(0) == PLAYER);
    }

    function testRaffelEnteredEmit() public {
        vm.startPrank(PLAYER);
        vm.deal(PLAYER, INITIAL_PLAYER_BALANCE);

        vm.expectEmit(true, false, false, false, address(raffel));
        emit RaffelEntered(PLAYER);
        raffel.enterRaffel{value: SEND_VALUE}();
    }
}
