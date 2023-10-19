// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import { PRBTest } from "@prb/test/PRBTest.sol";
import { DamnValuableToken } from "@contracts/CTF/Damn-Vulnerable-DeFi/00.Base/DamnValuableToken.sol";
import { PuppetV2Pool, PuppetV2Hack } from "@contracts/CTF/Damn-Vulnerable-DeFi/09.Puppet-V2.sol";

import { IWETH } from "@contracts/CTF/Damn-Vulnerable-DeFi/00.Base/WETH9.sol";
import { IUniswapV2Router02 } from "@uniswap/v2-periphery/contracts/interfaces/IUniswapV2Router02.sol";
import { IUniswapV2Factory } from "@uniswap/v2-core/contracts/interfaces/IUniswapV2Factory.sol";
import { IUniswapV2Pair } from "@uniswap/v2-core/contracts/interfaces/IUniswapV2Pair.sol";

/*
    forge test --match-path foundry/test/CTF/Damn-Vulnerable-DeFi/09.Puppet-V2.t.sol -vvvvv
*/

contract Challenge_9_Puppet_V2_Test is PRBTest {
    // hacking attack address
    address private deployer = address(1);
    address private player = address(2333);

    // Uniswap v2 exchange will start with 100 tokens and 10 WETH in liquidity
    uint256 private UNISWAP_INITIAL_TOKEN_RESERVE = 100 ether;
    uint256 private UNISWAP_INITIAL_WETH_RESERVE = 10 ether;
    // @audit-info 1DVT = ~0.1 ETH
    // @audit-info After we dump DVT: 1DVT = ~0.001 ETH

    uint256 private PLAYER_INITIAL_TOKEN_BALANCE = 10_000 ether;
    uint256 private PLAYER_INITIAL_ETH_BALANCE = 20 ether;

    uint256 private POOL_INITIAL_TOKEN_BALANCE = 1_000_000 ether;

    IWETH private weth;
    DamnValuableToken public token;
    PuppetV2Pool private lendingPool;
    IUniswapV2Pair private uniswapPair;
    IUniswapV2Factory private uniswapFactory;
    IUniswapV2Router02 private uniswapRouter;

    function setUp() public {
        vm.createSelectFork({ urlOrAlias: "mainnet" });
        vm.startPrank(deployer);
        vm.deal(deployer, type(uint256).max);
        _before();
        vm.stopPrank();
    }

    function _before() public {
        /* SETUP SCENARIO - NO NEED TO CHANGE ANYTHING HERE */
        vm.deal(player, PLAYER_INITIAL_ETH_BALANCE);
        assertEq(player.balance, PLAYER_INITIAL_ETH_BALANCE, "");
        token = new DamnValuableToken();

        // Deploy Uniswap Factory and Router
        // https://etherscan.io/address/0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D#code
        uniswapFactory = IUniswapV2Factory(0x5C69bEe701ef814a2B6a3EDD4B1652CB9cc5aA6f);
        // https://etherscan.io/address/0x5C69bEe701ef814a2B6a3EDD4B1652CB9cc5aA6f#code
        uniswapRouter = IUniswapV2Router02(0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D);

        // Deploy WETH
        // https://etherscan.io/token/0xc02aaa39b223fe8d0a0e5c4f27ead9083c756cc2#code
        weth = IWETH(0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2);

        // Approve tokens, and then create Uniswap v2 pair against WETH and add liquidity
        // The function takes care of deploying the pair automatically
        token.approve(address(uniswapRouter), UNISWAP_INITIAL_TOKEN_RESERVE);
        uniswapRouter.addLiquidityETH{ value: UNISWAP_INITIAL_WETH_RESERVE }(
            address(token), UNISWAP_INITIAL_TOKEN_RESERVE, 0, 0, deployer, block.timestamp * 2
        );

        // Get a reference to the created Uniswap pair
        uniswapPair = IUniswapV2Pair(uniswapFactory.getPair(address(token), address(weth)));
        // Deploy the lending pool
        lendingPool = new PuppetV2Pool(address(weth),address(token),address(uniswapPair),address(uniswapFactory));

        // Setup initial token balances of pool and player accounts
        token.transfer(player, PLAYER_INITIAL_TOKEN_BALANCE);
        token.transfer(address(lendingPool), POOL_INITIAL_TOKEN_BALANCE);

        // Check pool's been correctly setup
        assertEq(lendingPool.calculateDepositOfWETHRequired(1 ether), 0.3 ether, "");
        assertEq(lendingPool.calculateDepositOfWETHRequired(POOL_INITIAL_TOKEN_BALANCE), 300_000 ether, "");
    }

    function test_Exploit() public {
        vm.startPrank(player);
        /* START CODE YOUR SOLUTION HERE */

        PuppetV2Hack hackInst =
            new PuppetV2Hack(address(lendingPool), address(uniswapRouter), address(token), address(uniswapPair));
        token.transfer(address(hackInst), PLAYER_INITIAL_TOKEN_BALANCE);
        hackInst.attack{ value: PLAYER_INITIAL_ETH_BALANCE - 0.4 ether }();
        vm.stopPrank();

        /* END CODE YOUR SOLUTION */
        _after();
    }

    function _after() public {
        /* SUCCESS CONDITIONS - NO NEED TO CHANGE ANYTHING HERE */

        // Player has taken all tokens from the pool
        assertEq(token.balanceOf(address(lendingPool)), 0, "lendingPool has token");
        assertGte(token.balanceOf(player), POOL_INITIAL_TOKEN_BALANCE, "player not get all token");
    }
}
