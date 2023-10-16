// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract ReentrancyGuard {
    bool private entered;

    modifier nonReentrant() {
        require(!entered, "ReentrancyGuard: reentrant call");
        entered = true;
        _;
        entered = false;
    }
}
