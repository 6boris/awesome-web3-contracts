// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import { Test } from "@dev/forge-std/Test.sol";
import { WrappedEther, WrappedEtherExploit } from "@contracts/CTF/ONLYPWNER/05.WRAPPED-ETHER.sol";

/*
    forge test --match-path foundry/test/CTF/ONLYPWNER/05.WRAPPED-ETHER.t.sol -vvvv
*/

contract WRAPPED_ETHER_05_Test is Test {
    // hacking attack address
    address private hacker = address(1);
    address private other = address(2);
    WrappedEther private weth;

    function setUp() public {
        // Setup instance of the Ethernaut contract
        _before();
        // Deal attack address some ether
        vm.deal(hacker, 5 ether);
    }

    function _before() public {
        // 1.SetUp the exploit
        weth = new WrappedEther();

        weth.deposit{ value: 1 ether }(address(uint160(hacker) + 1));
        weth.deposit{ value: 1 ether }(address(uint160(hacker) + 2));
        weth.deposit{ value: 1 ether }(address(uint160(hacker) + 3));
        weth.deposit{ value: 1 ether }(address(uint160(hacker) + 4));
        weth.deposit{ value: 1 ether }(address(uint160(hacker) + 5));

        // payable(hacker).transfer(1 ether);
    }

    function test_Exploit() public {
        vm.startPrank(hacker);
        // 2.Run the exploit
        WrappedEtherExploit hackInst = new WrappedEtherExploit(address(weth));

        hackInst.attack{ value: 1 ether }();

        // 3.Verify the exploit
        _after();
    }

    function _after() public {
        vm.stopPrank();
        require(address(weth).balance == 0, "Not solved: weth  have token");
    }
}
