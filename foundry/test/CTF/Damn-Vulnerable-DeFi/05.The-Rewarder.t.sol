// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import { Test } from "@dev/forge-std/src/Test.sol";
import { DamnValuableToken } from "@contracts/CTF/Damn-Vulnerable-DeFi/00.Base/DamnValuableToken.sol";
import {
    FlashLoanerPool,
    TheRewarderPool,
    RewardToken,
    AccountingToken,
    FixedPointMathLib,
    TheRewarderHack
} from "@contracts/CTF/Damn-Vulnerable-DeFi/05.The-Rewarder.sol";
// OpenZeppelin v5 version
import { Math } from "@openzeppelin/contracts/utils/math/Math.sol";

/*
    forge test --match-path foundry/test/CTF/Damn-Vulnerable-DeFi/05.The-Rewarder.t.sol -vvvvv
*/
/* solhint-disable  reentrancy */
contract Challenge_5_The_Rewarder_Test is Test {
    using FixedPointMathLib for uint256;

    address private deployer = address(1);
    address private player = address(2333);

    address private alice = address(5);
    address private bob = address(6);
    address private charlie = address(7);
    address private david = address(8);
    address[4] private users = [alice, bob, charlie, david];

    TheRewarderPool private rewarderPool;
    RewardToken private rewardToken;
    AccountingToken private accountingToken;
    DamnValuableToken private liquidityToken;
    FlashLoanerPool private flashLoanPool;

    uint256 private TOKENS_IN_LENDER_POOL = 1_000_000 ether;

    function setUp() public {
        vm.label(deployer, "deployer");
        vm.label(player, "player");
        vm.label(alice, "alice");
        vm.label(bob, "bob");
        vm.label(charlie, "charlie");
        vm.label(david, "david");
        _before();
    }

    function _before() public {
        /* SETUP SCENARIO - NO NEED TO CHANGE ANYTHING HERE */
        liquidityToken = new DamnValuableToken();
        flashLoanPool = new FlashLoanerPool(address(liquidityToken));
        liquidityToken.transfer(address(flashLoanPool), TOKENS_IN_LENDER_POOL);

        rewarderPool = new TheRewarderPool(address(liquidityToken));
        rewardToken = RewardToken(rewarderPool.rewardToken());
        accountingToken = AccountingToken(rewarderPool.accountingToken());

        assertEq(accountingToken.owner(), address(rewarderPool));

        uint256 mintRole = accountingToken.MINTER_ROLE();
        uint256 snapShotRole = accountingToken.SNAPSHOT_ROLE();
        uint256 burnerRole = accountingToken.BURNER_ROLE();

        assertTrue(accountingToken.hasAllRoles(address(rewarderPool), mintRole | snapShotRole | burnerRole));

        uint256 depositAmount = 100 ether;
        for (uint256 i = 0; i < users.length; i++) {
            liquidityToken.transfer(users[i], depositAmount);
            vm.startPrank(users[i]);

            liquidityToken.approve(address(rewarderPool), depositAmount);
            rewarderPool.deposit(depositAmount);
            assertEq(accountingToken.balanceOf(users[i]), depositAmount);

            vm.stopPrank();
        }
        vm.warp(block.timestamp + 5 days);

        uint256 rewardInRound = rewarderPool.REWARDS();
        for (uint256 i = 0; i < users.length; i++) {
            vm.startPrank(users[i]);

            rewarderPool.distributeRewards();
            (, uint256 _tmp) = Math.tryDiv(rewardInRound, users.length);
            assertEq(rewardToken.balanceOf(users[i]), _tmp);

            vm.stopPrank();
        }
        assertEq(rewardToken.totalSupply(), rewardInRound);
        assertEq(liquidityToken.balanceOf(address(player)), 0);
        assertEq(rewarderPool.roundNumber(), 2);
        vm.warp(block.timestamp + 5 days);
    }

    function test_Exploit() public {
        vm.startPrank(player);
        /* START CODE YOUR SOLUTION HERE */

        TheRewarderHack hackInst =
        new TheRewarderHack(address(flashLoanPool), address(rewarderPool), address(liquidityToken), address(rewardToken));
        hackInst.attack();
        /* END CODE YOUR SOLUTION */
        vm.stopPrank();
        _after();
    }

    function _after() public {
        /* SUCCESS CONDITIONS - NO NEED TO CHANGE ANYTHING HERE */

        // It is no longer possible to execute flash loans
        assertEq(rewarderPool.roundNumber(), 3);
        for (uint256 i = 0; i < users.length; i++) {
            vm.startPrank(users[i]);
            rewarderPool.distributeRewards();
            uint256 userReward = rewardToken.balanceOf(users[i]);
            uint256 userDelta = userReward.rawSub(rewarderPool.REWARDS().rawDiv(users.length));
            assertTrue(userDelta < 1e16);
            vm.stopPrank();
        }

        // rewards must have been issued to the player account
        assertGt(rewardToken.totalSupply(), rewarderPool.REWARDS());
        uint256 playerRewards = rewardToken.balanceOf(address(player));
        assertGt(playerRewards, 0);

        // the amount of rewards earned should be close to total available amount
        uint256 delta = rewarderPool.REWARDS().rawSub(playerRewards);
        assertLt(delta, 1e17);

        // balance of dvt tokens is player and lending pool hasn't changed
        assertEq(liquidityToken.balanceOf(address(player)), 0);
        assertEq(liquidityToken.balanceOf(address(flashLoanPool)), TOKENS_IN_LENDER_POOL);
    }
}

/* solhint-enable  reentrancy */
