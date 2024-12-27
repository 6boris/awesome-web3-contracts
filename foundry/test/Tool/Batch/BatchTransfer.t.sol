// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import { Test } from "@dev/forge-std/Test.sol";
import { console } from "@dev/forge-std/console.sol";

import { ERC20 } from "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import { ERC721 } from "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import { BatchTransfer } from "@contracts/Tool/Batch/BatchTransfer.sol";
/*
    forge test -r http://localhost:8545 --match-path foundry/test/Tool/Batch/BatchTransfer.t.sol -vvvv
*/

contract TestERC20Token is ERC20 {
    constructor() ERC20("MyToken", "MTK") {
        _mint(msg.sender, 1000 ether);
    }
}

contract FallbackTest is Test {
    // hacking attack address
    address private admin = address(2333);
    address private player1 = address(1);
    address private player2 = address(2);
    ERC20 private erc20Token;
    ERC721 private erc721Token;
    BatchTransfer private batchTransferInst = new BatchTransfer();

    function setUp() public {
        vm.startPrank(admin);
        vm.deal(admin, 10 ether);
        erc20Token = new TestERC20Token();
        erc20Token.transfer(player1, 999 ether);
    }

    function test_ERC20_BatchTransfer() public {
        vm.startPrank(player1);
        erc20Token.approve(address(batchTransferInst), UINT256_MAX);

        uint256[] memory toAmountList = new uint256[](2);
        address[] memory toAddressList = new address[](2);
        toAmountList[0] = uint256(1);
        toAmountList[1] = uint256(1);
        toAddressList[0] = address(11);
        toAddressList[1] = address(12);

        batchTransferInst.BatchTransferERC20(erc20Token, toAddressList, toAmountList);

        _after();
    }

    function _after() public {
        vm.stopPrank();
    }
}
