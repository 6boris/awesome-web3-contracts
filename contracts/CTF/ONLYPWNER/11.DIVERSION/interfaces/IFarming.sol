// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IFarming {
    function deposit(uint256 amount) external;
    function withdraw(uint256 sharesAmount) external;
    function accumulateYield(address[] memory path) external;
}
