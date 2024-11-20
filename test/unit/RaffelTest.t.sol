// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity 0.8.24;

import {console} from "forge-std/console.sol";
import {Test} from "forge-std/Test.sol";
import {DeployRaffel} from "../../script/DeployRaffel.s.sol";
import {Raffel} from "../../src/Raffel.sol";
import {HelperConfig} from "../../script/HelperConfig.sol";

contract RaffelTest is Test {
    function setUp() external {
        DeployRaffel deployRaffel = new DeployRaffel();
        (Raffel raffel, HelperConfig helperConfig) = deployRaffel
            .deployContract();

        // console.log(address(raffel));
        // console.log(address(helperConfig));
    }
}
