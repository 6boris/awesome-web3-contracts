# Awesome Web3 Contracts

Holds the contracts that web3 developers use on a daily basis, including ethernaut, etc.

## Install Dependency

```yarn
yarn
```

Common install
It might take a while.

```bash
 forge install
```

Install spec lib version

```bash
git submodule add https://github.com/OpenZeppelin/openzeppelin-contracts foundry/lib/@openzeppelin/contracts-v4.7.3
cd foundry/lib/@openzeppelin/contracts-v4.7.3 && git checkout tags/v4.7.3 && cd ../../../../
```

```bash
# run test case
forge test

# run local node
anvil -f sepolia

# run script
forge script foundry/script/Deploy.s.sol --fork-url http://localhost:8545 --broadcast
```

## [Damn Vulnerable DeFi](https://www.damnvulnerabledefi.xyz/)

[Damn Vulnerable DeFi](https://www.damnvulnerabledefi.xyz/) is the wargame to learn offensive security of DeFi smart contracts in Ethereum. Featuring flash loans, price oracles, governance, NFTs, DEXs, lending pools, smart contract wallets, timelocks, and more!

| Level | Docs | Video | Note |
| -------- | --- | ------ | ---- |
| ✅ [1.Unstoppable]() | ...  | ... | ... |
|  [2.Naive receiver]() | ...  | ... | ... |
|  [3.Truster]() | ...  | ... | ... |
|  [4.Side Entrance]() | ...  | ... | ... |
|  [5.The Rewarder]() | ...  | ... | ... |
|  [6.Selfie]() | ...  | ... | ... |
|  [7.Compromised]() | ...  | ... | ... |
|  [8.Puppet]() | ...  | ... | ... |
|  [9.Puppet V2]() | ...  | ... | ... |
|  [10.Free Rider]() | ...  | ... | ... |
|  [11.Backdoor]() | ...  | ... | ... |
|  [12.Climber]() | ...  | ... | ... |
|  [13.Wallet Mining]() | ...  | ... | ... |
|  [14.Puppet V3]() | ...  | ... | ... |
|  [15.ABI Smuggling]() | ...  | ... | ... |


## [Ethernaut](https://ethernaut.openzeppelin.com/)

[Ethernaut](https://ethernaut.openzeppelin.com/) is a Web3 / Solidity based adversarial game inspired by overthewire.org, running on the Ethernaut virtual machine. Each level is a smart contract that needs to be hacked.


| Level | Docs | Video | Note |
| -------- | --- | ------ | ---- |
| ✅  [0.XXXX]() | [Mirror]()  | [YouTube]()、 [BILIBILI]() | ... |
| ✅  [0.Hello Ethernaut](https://ethernaut.openzeppelin.com/level/0x7E0f53981657345B31C59aC44e9c21631Ce710c7) | [Mirror]() | [YouTube](https://www.youtube.com/watch?v=BE0J7I13CPo)  、[BILIBILI](https://www.bilibili.com/video/BV1GV411w7bk) | ... |
|   [1.Fallback]() | [Mirror]()  | [YouTube]()、 [BILIBILI]() | ... |
|   [2.Fallout]() | [Mirror]()  | [YouTube]()、 [BILIBILI]() | ... |
|   [3.CoinFlip]() | [Mirror]()  | [YouTube]()、 [BILIBILI]() | ... |
|   [4.Telephone]() | [Mirror]()  | [YouTube]()、 [BILIBILI]() | ... |
|   [5.Token]() | [Mirror]()  | [YouTube]()、 [BILIBILI]() | ... |
|   [6.Delegate]() | [Mirror]()  | [YouTube]()、 [BILIBILI]() | ... |
|   [7.Force]() | [Mirror]()  | [YouTube]()、 [BILIBILI]() | ... |
|   [8.Vault]() | [Mirror]()  | [YouTube]()、 [BILIBILI]() | ... |
|   [9.King]() | [Mirror]()  | [YouTube]()、 [BILIBILI]() | ... |
|   [10.Reentrance]() | [Mirror]()  | [YouTube]()、 [BILIBILI]() | ... |


## [ONLYPWNER CTF](https://onlypwner.xyz)

ELEVATE YOUR EVM EXPERTISE WITH HANDS-ON CHALLENGES, COMPETE ON THE LEADERBOARD, AND JOIN A COMMUNITY OF SECURITY RESEARCHERS AND ENTHUSIASTS.

| Status | Level                                                    | Docs | Video | Note |
| :----: | :------------------------------------------------------- | :--: | :---: | :--: |
|   ✅   | [1.FREEBIE](https://onlypwner.xyz/challenges/5)          | ...  |  ...  | ...  |
|        | [2.TUTORIAL](https://onlypwner.xyz/challenges/1)         | ...  |  ...  | ...  |
|        | [3.REVERSE RUGPULL](https://onlypwner.xyz/challenges/7)  | ...  |  ...  | ...  |
|        | [4.UNDER THE FLOW](https://onlypwner.xyz/challenges/9)   | ...  |  ...  | ...  |
|        | [5.WRAPPED ETHER](https://onlypwner.xyz/challenges/12)   | ...  |  ...  | ...  |
|        | [6.ALL OR NOTHING](https://onlypwner.xyz/challenges/10)  | ...  |  ...  | ...  |
|        | [7.PLEASE SIGN HERE](https://onlypwner.xyz/challenges/6) | ...  |  ...  | ...  |
|        | [8.BRIDGE TAKEOVER](https://onlypwner.xyz/challenges/3)  | ...  |  ...  | ...  |
|        | [9.SHAPESHIFTER](https://onlypwner.xyz/challenges/8)     | ...  |  ...  | ...  |
|        | [10.13TH AIRDROP](https://onlypwner.xyz/challenges/2)    | ...  |  ...  | ...  |
|        | [11.DIVERSION](https://onlypwner.xyz/challenges/4)       | ...  |  ...  | ...  |
|        | [12.PAYDAY](https://onlypwner.xyz/challenges/11)         | ...  |  ...  | ...  |

