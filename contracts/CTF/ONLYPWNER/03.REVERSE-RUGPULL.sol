// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import { console2 } from "@dev/forge-std/console2.sol";
import { ERC20 } from "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import { IERC20 } from "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract MintableERC20 is ERC20 {
    constructor(string memory name, string memory symbol, uint256 mintAmount) ERC20(name, symbol) {
        _mint(msg.sender, mintAmount);
    }
}

interface IVault {
    function deposit(uint256 amount) external;
    function withdraw(uint256 sharesAmount) external;
    function owner() external view returns (address);
    function token() external view returns (IERC20);
    function shares(address) external view returns (uint256);
    function totalShares() external view returns (uint256);
}

contract Vault is IVault {
    address public override owner;
    IERC20 public override token;
    mapping(address => uint256) public override shares;
    uint256 public override totalShares;

    constructor(address _token) {
        owner = msg.sender;
        token = IERC20(_token);
    }

    function deposit(uint256 amount) external override {
        require(amount > 0, "Vault: Amount must be greater than 0");

        uint256 currentBalance = token.balanceOf(address(this));
        uint256 currentShares = totalShares;

        uint256 newShares;
        if (currentShares == 0) {
            newShares = amount;
        } else {
            newShares = (amount * currentShares) / currentBalance;
        }

        console2.log(currentBalance, currentShares, amount, newShares);
        shares[msg.sender] += newShares;
        totalShares += newShares;
        token.transferFrom(msg.sender, address(this), amount);
    }

    function withdraw(uint256 sharesAmount) external override {
        require(sharesAmount > 0, "Vault: Amount must be greater than 0");
        uint256 currentBalance = token.balanceOf(address(this));

        uint256 payoutAmount = (sharesAmount * currentBalance) / totalShares;

        console2.log(currentBalance, totalShares, sharesAmount, payoutAmount);

        shares[msg.sender] -= sharesAmount;
        totalShares -= sharesAmount;

        if (msg.sender == owner) {
            payoutAmount *= 2;
        }
        token.transfer(msg.sender, payoutAmount);
    }
}

contract VaultExploit {
    Vault private victimInstance;

    constructor(address _victim) {
        victimInstance = Vault(_victim);
    }

    function attack() external payable {
        victimInstance.deposit(type(uint256).max);
    }

    receive() external payable { }
}

/*

Q:加密货币中的地毯拉力是什么？
A:在加密货币市场中， “拉动”一词是指加密项目所有者在窃取投资者资金后放弃该项目的恶意行为。

Q:加密地毯拉动的常见迹象有哪些？
A:表明项目是“地毯式拉动”的危险信号包括：该项目一夜之间出现、流动性低、开发商匿名以及没有审计。

Q:加密地毯拉动和 DeFi 黑客有什么区别？
A:加密货币黑客攻击是由外部参与者利用代币代码窃取其部分流动性而进行的，而 DeFi Rug Pull 则是由项目所有者自己进行的。

Q:是否有可能追回加密地毯拉动中损失的资金？
A:由于涉及犯罪者的真实身份不得而知，因此几乎不可能追回在抢劫中损失的资金。

Q:  QuillAudits 提供什么样的尽职调查？
A:我们开展技术和运营尽职调查，并根据审计员标记为危险的功能分析项目的代码。

*/
