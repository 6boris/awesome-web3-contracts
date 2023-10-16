// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import { Test } from "@dev/forge-std/src/Test.sol";
import { GnosisSafe } from "@gnosis.pm/safe-contracts-v1.3.0/GnosisSafe.sol";
import { GnosisSafeProxyFactory } from "@gnosis.pm/safe-contracts-v1.3.0/proxies/GnosisSafeProxyFactory.sol";
import { DamnValuableToken } from "@contracts/CTF/Damn-Vulnerable-DeFi/00.Base/DamnValuableToken.sol";
import { WalletRegistry, BackdoorHack } from "@contracts/CTF/Damn-Vulnerable-DeFi/11.Backdoor.sol";

/*
    forge test --match-path foundry/test/CTF/Damn-Vulnerable-DeFi/11.Backdoor.t.sol -vvvvv
*/

contract Challenge_11_Backdoor_Test is Test {
    // hacking attack address
    address private deployer = address(1);
    address private feeRecipient = address(2);
    address private player = address(2333);

    address private alice = address(5);
    address private bob = address(6);
    address private charlie = address(7);
    address private david = address(8);
    address[] private _initialBeneficiaries;

    uint256 private AMOUNT_TOKENS_DISTRIBUTED = 40 ether;

    DamnValuableToken private token;
    GnosisSafe private masterCopy;
    GnosisSafeProxyFactory private walletFactory;
    WalletRegistry private walletRegistry;

    function setUp() public {
        vm.deal(deployer, type(uint256).max);
        _before();
        // vm.stopPrank();
    }

    function _before() public {
        /* SETUP SCENARIO - NO NEED TO CHANGE ANYTHING HERE */
        vm.startPrank(deployer);
        masterCopy = new GnosisSafe();
        walletFactory = new GnosisSafeProxyFactory();
        token = new DamnValuableToken();

        vm.label(alice, "alice");
        vm.label(bob, "bob");
        vm.label(charlie, "charlie");
        vm.label(david, "david");
        _initialBeneficiaries.push(alice);
        _initialBeneficiaries.push(bob);
        _initialBeneficiaries.push(charlie);
        _initialBeneficiaries.push(david);

        walletRegistry =
            new WalletRegistry(address(masterCopy),address(walletFactory), address(token), _initialBeneficiaries);
        token.transfer(address(walletRegistry), AMOUNT_TOKENS_DISTRIBUTED);

        assertEq(walletRegistry.owner(), deployer, "");
        for (uint256 i = 0; i < _initialBeneficiaries.length; i++) {
            assertTrue(walletRegistry.beneficiaries(_initialBeneficiaries[i]), "");
            vm.startPrank(_initialBeneficiaries[i]);
            vm.expectRevert();
            walletRegistry.addBeneficiary(_initialBeneficiaries[i]);
            vm.stopPrank();
        }
    }

    function test_Exploit() public {
        vm.startPrank(player);
        /* START CODE YOUR SOLUTION HERE */

        new BackdoorHack(address(walletRegistry), _initialBeneficiaries);

        /* END CODE YOUR SOLUTION */
        vm.stopPrank();
        _after();
    }

    function _after() public {
        /* SUCCESS CONDITIONS - NO NEED TO CHANGE ANYTHING HERE */
        vm.startPrank(deployer);

        // Player must have used a single transaction [forge doesn't seem to support]
        // expect(await ethers.provider.getTransactionCount(player.address)).to.eq(1);

        for (uint256 i = 0; i < _initialBeneficiaries.length; i++) {
            // User must have registered a wallet
            address wallet = walletRegistry.wallets(_initialBeneficiaries[i]);
            assertTrue(wallet != address(0), "");
            // User is no longer registered as a beneficiary
            assertFalse(walletRegistry.beneficiaries(_initialBeneficiaries[i]));
        }
        // Player must own all tokens
        assertEq(token.balanceOf(player), AMOUNT_TOKENS_DISTRIBUTED, "AMOUNT_TOKENS_DISTRIBUTED");
        vm.stopPrank();
    }
}
