// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.24;

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

    address payable[] private s_players;
    uint256 private s_lastTimeStamp;
    uint256 private immutable i_entranceFee;
    uint256 private immutable i_interval;

    event RaffelEntered(address);

    // functions
    constructor(
        uint enteranceFee,
        address _vrfCoordinator
    ) VRFConsumerBaseV2Plus(_vrfCoordinator) {
        i_entranceFee == enteranceFee;
        s_lastTimeStamp == block.timestamp;
    }

    function enterRaffel() external payable {
        if (msg.value < i_entranceFee) {
            revert Raffel__SendMoreEth();
        }

        s_players.push(payable(msg.sender));
        emit RaffelEntered(msg.sender);
    }

    function pickWinner() external view {
        if (s_lastTimeStamp - block.timestamp > i_interval) {
            revert();
        }
        // vrf logic here
    }

    // fulfillRandomWords function
    function fulfillRandomWords(
        uint256 requestId,
        uint256[] calldata randomWords
    ) internal override {}

    // getter function
    function getEntranceFee() external view returns (uint256) {
        return i_entranceFee;
    }
}
