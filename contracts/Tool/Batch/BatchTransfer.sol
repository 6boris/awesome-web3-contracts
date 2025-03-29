// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import { ERC20 } from "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import { ERC721 } from "@openzeppelin/contracts/token/ERC721/ERC721.sol";

contract BatchTransfer {
    function BatchTransferNative(address[] calldata toAddressList, uint256[] calldata toAmountList) external payable {
        require(toAddressList.length == toAmountList.length, "Params num not match");
        for (uint256 i = 0; i < toAmountList.length; i++) {
            payable(toAddressList[i]).transfer(toAmountList[i]);
        }
    }

    function BatchTransferERC20(
        ERC20 token,
        address[] calldata toAddressList,
        uint256[] calldata toAmountList
    )
        external
    {
        require(toAddressList.length == toAmountList.length, "Params num not match");
        for (uint256 idx = 0; idx < toAddressList.length; idx++) {
            require(
                token.transferFrom(msg.sender, toAddressList[idx], toAmountList[idx]), "Transfer ERC20 Token Failed"
            );
        }
    }

    function BatchTransferERC721(
        ERC721 token,
        address[] calldata toAddressList,
        uint256[] calldata toTokenIDList
    )
        external
    {
        require(toAddressList.length == toTokenIDList.length, "Params num not match");
        for (uint256 idx = 0; idx < toAddressList.length; idx++) {
            token.transferFrom(msg.sender, toAddressList[idx], toTokenIDList[idx]);
        }
    }
}
