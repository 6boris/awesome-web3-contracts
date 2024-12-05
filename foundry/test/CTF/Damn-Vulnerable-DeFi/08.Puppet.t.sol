// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import { PRBTest } from "@prb/test/PRBTest.sol";
import { console2 } from "@dev/forge-std/console2.sol";
import { DamnValuableToken } from "@contracts/CTF/Damn-Vulnerable-DeFi/00.Base/DamnValuableToken.sol";

import {
    PuppetPool,
    IUniswapV1Exchange,
    IUniswapV1Factory,
    PuppetHack
} from "@contracts/CTF/Damn-Vulnerable-DeFi/08.Puppet.sol";

/*
    forge test --match-path foundry/test/CTF/Damn-Vulnerable-DeFi/08.Puppet.t.sol -vvvvv
*/

contract Challenge_8_Puppet_Test is PRBTest {
    address private deployer = address(1);
    address private player = address(2);
    address private player2 = address(3);

    uint256 private UNISWAP_INITIAL_TOKEN_RESERVE = 10 ether;
    uint256 private UNISWAP_INITIAL_ETH_RESERVE = 10 ether;

    uint256 private PLAYER_INITIAL_TOKEN_BALANCE = 1000 ether;
    uint256 private PLAYER_INITIAL_ETH_BALANCE = 25 ether;

    uint256 private POOL_INITIAL_TOKEN_BALANCE = 100_000 ether;

    DamnValuableToken public token;
    DamnValuableToken public exchangeTemplate;
    IUniswapV1Factory public uniswapFactory;
    IUniswapV1Exchange public uniswapExchange;
    PuppetPool public lendingPool;

    function setUp() public {
        vm.createSelectFork({ urlOrAlias: "mainnet" });
        vm.label(deployer, "deployer");
        vm.label(player, "player");
        vm.label(player2, "player2");

        vm.deal(deployer, type(uint256).max);
        vm.startPrank(deployer);
        _before();
        vm.stopPrank();
    }

    function _before() public {
        /* SETUP SCENARIO - NO NEED TO CHANGE ANYTHING HERE */

        // Deploy token to be traded in Uniswap
        token = new DamnValuableToken();

        uniswapFactory = IUniswapV1Factory(0xc0a47dFe034B400B47bDaD5FecDa2621de6c4d95);
        vm.label(0xc0a47dFe034B400B47bDaD5FecDa2621de6c4d95, "UniswapV1Factory");
        // Create a new exchange for the token, and retrieve the deployed exchange's address
        uniswapExchange = IUniswapV1Exchange(uniswapFactory.createExchange(address(token)));
        vm.label(address(uniswapExchange), "UniswapV1Exchange");

        vm.deal(player, PLAYER_INITIAL_ETH_BALANCE);

        // Deploy the lending pool
        lendingPool = new PuppetPool(address(token), address(uniswapExchange));

        assertEq(player.balance, PLAYER_INITIAL_ETH_BALANCE, "");

        // Add initial token and ETH liquidity to the pool
        token.approve(address(uniswapExchange), UNISWAP_INITIAL_TOKEN_RESERVE);
        uniswapExchange.addLiquidity{ value: UNISWAP_INITIAL_ETH_RESERVE }(
            0, UNISWAP_INITIAL_TOKEN_RESERVE, block.timestamp * 2
        );

        // Ensure Uniswap exchange is working as expected
        // TODO ...
        // uniswapExchange.getTokenToEthInputPrice(10 ether);

        // Setup initial token balances of pool and player accounts
        token.transfer(player, PLAYER_INITIAL_TOKEN_BALANCE);
        token.transfer(address(lendingPool), POOL_INITIAL_TOKEN_BALANCE);

        // Ensure correct setup of pool. For example, to borrow 1 need to deposit 2
        assertEq(lendingPool.calculateDepositRequired(10 ether), 10 ether * 2, "");
        assertEq(lendingPool.calculateDepositRequired(POOL_INITIAL_TOKEN_BALANCE), POOL_INITIAL_TOKEN_BALANCE * 2, "");
    }

    function test_Exploit() public {
        /* START CODE YOUR SOLUTION HERE */
        vm.startPrank(player2);
        PuppetHack hackInst = new PuppetHack(address(token), address(uniswapExchange), address(lendingPool), player);
        vm.stopPrank();

        vm.startPrank(player);
        token.transfer(address(hackInst), PLAYER_INITIAL_TOKEN_BALANCE);
        hackInst.attack{ value: 20 ether }();

        // token.transfer(address(hackInst), token.balanceOf(player2));

        /* END CODE YOUR SOLUTION */
        vm.stopPrank();
        _after();
    }

    function _after() public {
        /* SUCCESS CONDITIONS - NO NEED TO CHANGE ANYTHING HERE */
        console2.log("START SUCCESS CONDITIONS VERIFY");
        vm.startPrank(deployer);

        // Player executed a single transaction
        // expect(await ethers.provider.getTransactionCount(player.address)).to.eq(1);

        // Player has taken all tokens from the pool
        assertEq(token.balanceOf(address(lendingPool)), 0, "lendingPool has token");

        // Player has taken all tokens from the pool
        assertGte(token.balanceOf(player), POOL_INITIAL_TOKEN_BALANCE, "player not get all token");

        vm.stopPrank();
    }
}
