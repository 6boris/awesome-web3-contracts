// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import { PRBTest } from "@prb/test/PRBTest.sol";
import { DamnValuableNFT } from "@contracts/CTF/Damn-Vulnerable-DeFi/00.Base/DamnValuableNFT.sol";
import { DamnValuableToken } from "@contracts/CTF/Damn-Vulnerable-DeFi/00.Base/DamnValuableToken.sol";
import {
    FreeRiderNFTMarketplace,
    FreeRiderRecovery,
    FreeRiderHack,
    IWETH
} from "@contracts/CTF/Damn-Vulnerable-DeFi/10.Free-Rider.sol";
import { IUniswapV2Router02 } from "@uniswap/v2-periphery/contracts/interfaces/IUniswapV2Router02.sol";
import { IUniswapV2Factory } from "@uniswap/v2-core/contracts/interfaces/IUniswapV2Factory.sol";
import { IUniswapV2Factory } from "@uniswap/v2-core/contracts/interfaces/IUniswapV2Factory.sol";
import { IUniswapV2Pair } from "@uniswap/v2-core/contracts/interfaces/IUniswapV2Pair.sol";

/*
    forge test --match-path foundry/test/CTF/Damn-Vulnerable-DeFi/10.Free-Rider.t.sol -vvvvv
*/
/* solhint-disable  max-states-count,avoid-tx-origin */
contract Challenge_10_Free_Rider_Test is PRBTest {
    // hacking attack address
    address private deployer = address(1);
    address private devs = address(2);
    address private player = address(2333);

    // The NFT marketplace will have 6 tokens, at 15 ETH each
    uint256 private NFT_PRICE = 15 ether;
    uint256 private constant AMOUNT_OF_NFTS = 6;
    uint256 private MARKETPLACE_INITIAL_ETH_BALANCE = 90 ether;
    uint256 private PLAYER_INITIAL_ETH_BALANCE = 0.1 ether;
    uint256 private BOUNTY = 45 ether;
    // Initial reserves for the Uniswap v2 pool
    uint256 private UNISWAP_INITIAL_TOKEN_RESERVE = 15_000 ether;
    uint256 private UNISWAP_INITIAL_WETH_RESERVE = 9000 ether;

    IWETH private weth;
    IUniswapV2Router02 private uniswapRouter;
    IUniswapV2Factory private uniswapFactory;
    IUniswapV2Pair private uniswapPair;
    DamnValuableToken private token;
    DamnValuableNFT private nft;
    FreeRiderNFTMarketplace private marketplace;
    FreeRiderRecovery private devsContract;

    uint256[] private _offerManyTokenIds;
    uint256[] private _offerManyPrices;

    function setUp() public {
        // vm.startPrank(deployer);
        vm.createSelectFork({ urlOrAlias: "mainnet" });
        vm.deal(deployer, type(uint256).max);
        vm.deal(devs, type(uint256).max);
        _before();
        // vm.stopPrank();
    }

    function _before() public {
        /* SETUP SCENARIO - NO NEED TO CHANGE ANYTHING HERE */

        // Player starts with limited ETH balance
        vm.deal(player, PLAYER_INITIAL_ETH_BALANCE);
        assertEq(player.balance, PLAYER_INITIAL_ETH_BALANCE);
        // Deploy WETH
        // https://etherscan.io/token/0xc02aaa39b223fe8d0a0e5c4f27ead9083c756cc2#code
        weth = IWETH(0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2);

        // Deploy token to be traded against WETH in Uniswap v2
        token = new DamnValuableToken();

        // Deploy Uniswap Factory and Router
        // https://etherscan.io/address/0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D#code
        uniswapFactory = IUniswapV2Factory(0x5C69bEe701ef814a2B6a3EDD4B1652CB9cc5aA6f);
        // https://etherscan.io/address/0x5C69bEe701ef814a2B6a3EDD4B1652CB9cc5aA6f#code
        uniswapRouter = IUniswapV2Router02(0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D);
        // Approve tokens, and then create Uniswap v2 pair against WETH and add liquidity
        // The function takes care of deploying the pair automatically
        token.approve(address(uniswapRouter), UNISWAP_INITIAL_TOKEN_RESERVE);
        uniswapRouter.addLiquidityETH{ value: UNISWAP_INITIAL_WETH_RESERVE }(
            address(token), UNISWAP_INITIAL_TOKEN_RESERVE, 0, 0, deployer, block.timestamp * 2
        );

        // Get a reference to the created Uniswap pair
        uniswapPair = IUniswapV2Pair(uniswapFactory.getPair(address(token), address(weth)));

        assertEq(uniswapPair.token0(), address(token), "");
        assertEq(uniswapPair.token1(), address(weth), "");
        assertGt(uniswapPair.balanceOf(deployer), 0, "");
        vm.startPrank(deployer);
        // Deploy the marketplace and get the associated ERC721 token
        // The marketplace will automatically mint AMOUNT_OF_NFTS to the deployer (see
        marketplace = new FreeRiderNFTMarketplace{ value: MARKETPLACE_INITIAL_ETH_BALANCE }(AMOUNT_OF_NFTS);

        // Deploy NFT contract
        nft = DamnValuableNFT(marketplace.token());
        assertEq(nft.owner(), address(0), "");
        assertEq(nft.rolesOf(address(marketplace)), nft.MINTER_ROLE(), "");

        // Ensure deployer owns all minted NFTs. Then approve the marketplace to trade them.
        for (uint256 id = 1; id < AMOUNT_OF_NFTS; id++) {
            assertEq(nft.ownerOf(id), deployer, "nft.ownerOf(id)");
        }
        nft.setApprovalForAll(address(marketplace), true);
        // Open offers in the marketplace
        for (uint256 id = 0; id < AMOUNT_OF_NFTS; id++) {
            _offerManyTokenIds.push(id);
            _offerManyPrices.push(NFT_PRICE);
        }
        marketplace.offerMany(_offerManyTokenIds, _offerManyPrices);

        // Deploy devs' contract, adding the player as the beneficiary
        // mock player => tx.origin
        vm.startPrank(devs);
        devsContract = new FreeRiderRecovery{ value: BOUNTY }(tx.origin, address(nft));
        vm.stopPrank();
    }

    function test_Exploit() public {
        vm.startPrank(player);
        /* START CODE YOUR SOLUTION HERE */

        // ...
        FreeRiderHack hackInst =
        new  FreeRiderHack(address(uniswapPair), payable(marketplace), address(weth), address(nft), address(devsContract));
        (bool isSuccess,) = address(hackInst).call{ value: player.balance }("");
        assertEq(isSuccess, true, "");
        hackInst.attack();

        /* END CODE YOUR SOLUTION */
        vm.stopPrank();

        _after();
    }

    function _after() public {
        /* SUCCESS CONDITIONS - NO NEED TO CHANGE ANYTHING HERE */
        vm.startPrank(devs);

        // The devs extract all NFTs from its associated contract
        for (uint256 tokenId = 0; tokenId < AMOUNT_OF_NFTS; tokenId++) {
            nft.transferFrom(address(devsContract), devs, tokenId);
            assertEq(nft.ownerOf(tokenId), devs, "");
        }

        // Exchange must have lost NFTs and ETH
        assertEq(marketplace.offersCount(), 0, "");

        // Player must have earned all ETH
        assertLt(address(marketplace).balance, MARKETPLACE_INITIAL_ETH_BALANCE, "");
        assertEq(address(devsContract).balance, 0, "");
        vm.stopPrank();
    }
}
/* solhint-enable   max-states-count,avoid-tx-origin */
