// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

// Wrapped Ether https://etherscan.io/token/0xc02aaa39b223fe8d0a0e5c4f27ead9083c756cc2#code
interface IWETH {
    function name() external view returns (string memory);
    function approve(address guy, uint256 amount) external returns (bool);
    function totalSupply() external view returns (uint256);
    function transferFrom(address src, address dst, uint256 amount) external returns (bool);
    function withdraw(uint256 amount) external;
    function decimals() external view returns (uint8);
    function balanceOf(address) external view returns (uint256);
    function symbol() external view returns (string memory);
    function transfer(address dst, uint256 amount) external returns (bool);
    function deposit() external payable;
    function allowance(address, address) external view returns (uint256);

    event Approval(address indexed src, address indexed guy, uint256 amount);
    event Transfer(address indexed src, address indexed dst, uint256 amount);
    event Deposit(address indexed dst, uint256 amount);
    event Withdrawal(address indexed src, uint256 amount);
}
