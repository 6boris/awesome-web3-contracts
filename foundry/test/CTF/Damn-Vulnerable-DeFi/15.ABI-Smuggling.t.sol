// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import { PRBTest } from "@prb/test/PRBTest.sol";
import { DamnValuableToken } from "@contracts/CTF/Damn-Vulnerable-DeFi/00.Base/DamnValuableToken.sol";
import { SelfAuthorizedVault, IERC20 } from "@contracts/CTF/Damn-Vulnerable-DeFi/15.ABI-Smuggling.sol";

/*
    forge test --match-path foundry/test/CTF/Damn-Vulnerable-DeFi/15.ABI-Smuggling.t.sol -vvvvv
*/

contract Challenge_15_ABI_Smuggling_Test is PRBTest {
    // hacking attack address
    address private deployer = address(1);
    address private recovery = address(2);
    address private player = address(2333);

    uint256 private VAULT_TOKEN_BALANCE = 1_000_000 ether;

    DamnValuableToken public token;
    SelfAuthorizedVault public vault;

    bytes32[] private _initPermissions;

    function setUp() public {
        vm.startPrank(deployer);
        vm.deal(deployer, type(uint256).max);
        _before();
        vm.stopPrank();
    }

    function _before() public {
        /* SETUP SCENARIO - NO NEED TO CHANGE ANYTHING HERE */

        // Deploy Damn Valuable Token contract
        token = new DamnValuableToken();

        // Deploy Vault
        vault = new SelfAuthorizedVault();

        // Set permissions
        bytes32 deployerPermission = vault.getActionId(bytes4(bytes("0x85fb709d")), deployer, address(vault));
        bytes32 playerPermission = vault.getActionId(bytes4(bytes("0xd9caed12")), player, address(vault));
        _initPermissions.push(deployerPermission);
        _initPermissions.push(playerPermission);
        vault.setPermissions(_initPermissions);
        assertTrue(vault.permissions(deployerPermission), "");
        assertTrue(vault.permissions(playerPermission), "");

        // Make sure Vault is initialized
        assertTrue(vault.initialized(), "");

        // Deposit tokens into the vault
        token.transfer(address(vault), VAULT_TOKEN_BALANCE);
        assertEq(token.balanceOf(address(vault)), VAULT_TOKEN_BALANCE, "");
        assertEq(token.balanceOf(player), 0, "");

        // Cannot call Vault directly
        vm.expectRevert(SelfAuthorizedVault.CallerNotAllowed.selector);
        vault.sweepFunds(deployer, IERC20(address(token)));
        vm.startPrank(player);
        vm.expectRevert(SelfAuthorizedVault.CallerNotAllowed.selector);
        vault.withdraw(address(token), player, 1 ether);
    }

    function test_Exploit() public {
        vm.startPrank(player);
        /* START CODE YOUR SOLUTION HERE */

        /* END CODE YOUR SOLUTION */
        vm.stopPrank();
        // _after();
    }

    function _after() public {
        /* SUCCESS CONDITIONS - NO NEED TO CHANGE ANYTHING HERE */
        assertEq(token.balanceOf(address(vault)), 0, "");
        assertEq(token.balanceOf(player), 0, "");
        assertEq(token.balanceOf(address(recovery)), VAULT_TOKEN_BALANCE, "");
    }
}
