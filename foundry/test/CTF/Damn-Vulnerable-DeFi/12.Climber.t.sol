// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import { Test } from "@dev/forge-std/src/Test.sol";
import { DamnValuableToken } from "@contracts/CTF/Damn-Vulnerable-DeFi/00.Base/DamnValuableToken.sol";
import { ClimberVault } from "@contracts/CTF/Damn-Vulnerable-DeFi/12.Climber.sol";

/*
    forge test --match-path foundry/test/CTF/Damn-Vulnerable-DeFi/12.Climber.t.sol -vvvvv
*/

contract Challenge_12_Climber_Test is Test {
    // hacking attack address
    address private deployer = address(1);
    address private proposer = address(2);
    address private sweeper = address(2);
    address private player = address(2333);

    uint256 private VAULT_TOKEN_BALANCE = 10_000_000 ether;
    uint256 private PLAYER_INITIAL_ETH_BALANCE = 0.1 ether;
    uint256 private TIMELOCK_DELAY = 60 * 60;

    DamnValuableToken public token;
    ClimberVault private valut;

    function setUp() public {
        vm.startPrank(deployer);
        vm.deal(deployer, type(uint256).max);
        _before();
        vm.stopPrank();
    }

    function _before() public {
        /* SETUP SCENARIO - NO NEED TO CHANGE ANYTHING HERE */
        token = new DamnValuableToken();
        valut = new ClimberVault();
        // valut.initialize(deployer, proposer, sweeper);
    }

    function test_Exploit() public {
        /* START CODE YOUR SOLUTION HERE */

        // ...

        /* END CODE YOUR SOLUTION */
        vm.startPrank(deployer);
        _after();
    }

    function _after() public {
        /* SUCCESS CONDITIONS - NO NEED TO CHANGE ANYTHING HERE */
        assertEq(token.totalSupply(), type(uint256).max, "CHECK totalSupply()");
        vm.stopPrank();
    }
}
