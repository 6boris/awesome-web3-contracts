// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import { ERC20 } from "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract MintableERC20 is ERC20 {
    address public owner;

    constructor(string memory name, string memory symbol) ERC20(name, symbol) {
        owner = msg.sender;
    }

    function mint(address to, uint256 amount) external {
        require(msg.sender == owner, "MintableERC20: Only owner can mint");
        _mint(to, amount);
    }

    function transferOwnership(address newOwner) external {
        require(msg.sender == owner, "MintableERC20: Only owner can transfer ownership");
        owner = newOwner;
    }
}
