// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.24;

import {console} from "forge-std/console.sol";
import {VRFConsumerBaseV2Plus} from "../lib/chainlink-brownie-contracts/contracts/src/v0.8/vrf/dev/VRFConsumerBaseV2Plus.sol";
import {VRFV2PlusClient} from "../lib/chainlink-brownie-contracts/contracts/src/v0.8/vrf/dev/libraries/VRFV2PlusClient.sol";

/**
 * @title A raffel contract
 * @author Jeremiah T.A
 * @notice This is a raffel smart contract for lottery
 * @dev This contract is designed to be used with Chainlink's VRF2.5 (Verifiable Random Function)
 */
contract Raffel is VRFConsumerBaseV2Plus {
    error Raffel__SendMoreEth();
    error Raffel__TransferFailed();
    error Raffel_RaffelNotOpen();
    error Raffel__UpkeepNotNeeded(
        uint256 balance,
        uint256 playersLength,
        uint256 raffelStatus
    );

    /**
     * Type declaration
     */
    enum RaffelStatus {
        OPEN,
        CALCULATING
    }

    /**
     * State Variables
     */
    uint32 private constant NUM_WORDS = 1;
    uint16 private constant REQUEST_CONFIRMATIONS = 3;

    uint256 private immutable i_entranceFee;
    uint256 private immutable i_interval;
    bytes32 private immutable i_keyHash;
    uint256 private immutable i_subscriptionId;
    uint32 private immutable i_callbackGasLimit;

    uint256 private s_lastTimeStamp;
    address payable[] private s_players;
    address payable private s_recentWinner;
    RaffelStatus private s_raffelStatus;

    event RaffelEntered(address indexed player);
    event RaffelWinner(address indexed);

    // functions
    constructor(
        uint256 entranceFee,
        uint256 interval,
        address _vrfCoordinator,
        bytes32 _keyHash,
        uint256 _subscriptionId,
        uint32 _callbackGasLimit
    ) VRFConsumerBaseV2Plus(_vrfCoordinator) {
        i_entranceFee = entranceFee;
        i_interval = interval;
        s_lastTimeStamp = block.timestamp;

        s_vrfCoordinator.requestRandomWords;
        i_keyHash = _keyHash;
        i_subscriptionId = _subscriptionId;
        i_callbackGasLimit = _callbackGasLimit;
        s_raffelStatus = RaffelStatus.OPEN;
    }

    function enterRaffel() external payable {
        if (msg.value < i_entranceFee) {
            revert Raffel__SendMoreEth();
        }

        if (s_raffelStatus != RaffelStatus.OPEN) {
            revert Raffel_RaffelNotOpen();
        }

        s_players.push(payable(msg.sender));
        emit RaffelEntered(msg.sender);
    }

    /**
     * @dev This is the function that the Chainlink Keeper nodes call
     * they look for `upkeepNeeded` to return True.
     * the following should be true for this to return true:
     * 1. The time interval has passed between raffle runs.
     * 2. The lottery is open.
     * 3. The contract has ETH.
     * 4. Implicity, your subscription is funded with LINK.
     */
    function checkUpkeep(
        bytes memory /* checkData */
    ) public view returns (bool upkeepNeeded, bytes memory /* performData */) {
        bool timeHasPassed = (block.timestamp - s_lastTimeStamp) >= i_interval;
        bool raffelIsOpen = s_raffelStatus == RaffelStatus.OPEN;
        bool raffelHasEth = address(this).balance > 0;
        bool raffelHasPlayers = s_players.length > 0;

        upkeepNeeded = (timeHasPassed &&
            raffelIsOpen &&
            raffelHasEth &&
            raffelHasPlayers);

        return (upkeepNeeded, "");
    }

    function performUpkeep(bytes calldata /*performData*/) external {
        // console.log("Block Timestamp:", block.timestamp);
        // console.log("Interval:", i_interval);
        // console.log("Last TimeStamp:", s_lastTimeStamp);

        (bool upkeepNeeded, ) = checkUpkeep("");
        if (!upkeepNeeded) {
            revert Raffel__UpkeepNotNeeded(
                address(this).balance,
                s_players.length,
                uint256(s_raffelStatus)
            );
        }

        s_raffelStatus = RaffelStatus.CALCULATING;

        VRFV2PlusClient.RandomWordsRequest memory request = VRFV2PlusClient
            .RandomWordsRequest({
                keyHash: i_keyHash,
                subId: i_subscriptionId,
                requestConfirmations: REQUEST_CONFIRMATIONS,
                callbackGasLimit: i_callbackGasLimit,
                numWords: NUM_WORDS,
                // Set nativePayment to true to pay for VRF requests with Sepolia ETH instead of LINK
                extraArgs: VRFV2PlusClient._argsToBytes(
                    VRFV2PlusClient.ExtraArgsV1({nativePayment: false})
                )
            });

        s_vrfCoordinator.requestRandomWords(request);
    }

    // CEI: Check, Effect, Interaction
    // fulfillRandomWords function
    function fulfillRandomWords(
        uint256,
        /*requestId*/
        uint256[] calldata randomWords
    ) internal override {
        // Check

        // Effects
        uint256 indexOfWinner = randomWords[0] % s_players.length;
        address payable recentWinner = s_players[indexOfWinner];
        s_recentWinner = recentWinner;
        s_raffelStatus = RaffelStatus.OPEN;
        s_players = new address payable[](0);
        s_lastTimeStamp = block.timestamp;
        emit RaffelWinner(s_recentWinner);

        (bool success, ) = recentWinner.call{value: address(this).balance}("");

        if (!success) {
            revert Raffel__TransferFailed();
        }
    }

    //* getter function */
    function getEntranceFee() external view returns (uint256) {
        return i_entranceFee;
    }

    function getRaffelStatus() external view returns (RaffelStatus) {
        return s_raffelStatus;
    }

    function getPlayers(
        uint256 _index
    ) external view returns (address payable) {
        return s_players[_index];
    }
}
