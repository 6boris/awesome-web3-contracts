// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import { Test } from "@dev/forge-std/src/Test.sol";
import { DamnValuableToken } from "@contracts/CTF/Damn-Vulnerable-DeFi/00.Base/DamnValuableToken.sol";

/*
    forge test --match-path foundry/test/CTF/Damn-Vulnerable-DeFi/13.Wallet-Mining.t.sol -vvvvv
*/

contract Challenge_13_Wallet_Mining_Test is Test {
    // hacking attack address
    address private deployer = address(1);
    address private feeRecipient = address(2);
    address private player = address(2333);
    DamnValuableToken public token;

    function setUp() public {
        vm.startPrank(deployer);
        vm.deal(deployer, type(uint256).max);
        _before();
        vm.stopPrank();
    }

    function _before() public {
        /* SETUP SCENARIO - NO NEED TO CHANGE ANYTHING HERE */
        token = new DamnValuableToken();
    }

    function test_Exploit() public {
        /* START CODE YOUR SOLUTION HERE */

        // ...

        /* END CODE YOUR SOLUTION */
        vm.startPrank(deployer);
        _after();
    }

    function _after() public {
        /* SUCCESS CONDITIONS - NO NEED TO CHANGE ANYTHING HERE */
        assertEq(token.totalSupply(), type(uint256).max, "CHECK totalSupply()");
        vm.stopPrank();
    }
}
