# Awesome Web3 Contracts

Holds the contracts that web3 developers use on a daily basis, including ethernaut, etc.

## Install Dependency

```yarn
yarn install
forge soldeer install
forge soldeer install @openzeppelin-contracts~4.7.3
forge soldeer install @openzeppelin-contracts~5.2.0

forge soldeer install @openzeppelin-contracts-upgradeable~4.7.3
forge soldeer install @openzeppelin-contracts-upgradeable~5.2.0
```

```bash
# run test case
forge test

# run local node
anvil -f sepolia

# run script
forge script foundry/script/Deploy.s.sol --fork-url http://localhost:8545 --broadcast
```

## Damn Vulnerable DeFi

[Damn Vulnerable DeFi](https://www.damnvulnerabledefi.xyz/) is the wargame to learn offensive security of DeFi smart
contracts in Ethereum. Featuring flash loans, price oracles, governance, NFTs, DEXs, lending pools, smart contract
wallets, timelocks, and more. I also do videos on CTF on
[BILIBILI](https://www.bilibili.com/list/3493272831920239?desc=0&sid=3695249&bvid=BV1aw411C7E8) and
[YouTube](https://www.youtube.com/watch?v=GJwiet8NGS4&list=PLYYL7LUg7BXTTOHhLmh4zjOwdSjhnKtVE&index=1), so feel free to
**_SUBSCRIBE_** OR **_一键三连_**.

| Level                                                                                | Docs | Video                                                                                                                                                                                                   | Note |
| ------------------------------------------------------------------------------------ | ---- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | ---- |
| ✅ [1.Unstoppable](https://www.damnvulnerabledefi.xyz/challenges/unstoppable/)       | ...  | [BILIBILI](https://www.bilibili.com/list/3493272831920239?desc=0&sid=3695249&bvid=BV1wN411t7Ss)、[YouTube](https://www.youtube.com/watch?v=DcH2fm30i_o&list=PLYYL7LUg7BXTTOHhLmh4zjOwdSjhnKtVE&index=2) | ...  |
| ✅ [2.Naive receiver](https://www.damnvulnerabledefi.xyz/challenges/naive-receiver/) | ...  | [BILIBILI](https://www.bilibili.com/list/3493272831920239?desc=0&sid=3695249&bvid=BV1nN411t7FM)                                                                                                         | ...  |
| ✅ [3.Truster](https://www.damnvulnerabledefi.xyz/challenges/truster/)               | ...  | [BILIBILI](https://www.bilibili.com/list/3493272831920239?desc=0&sid=3695249&bvid=BV1iQ4y1s7Vy)                                                                                                         | ...  |
| ✅ [4.Side Entrance](https://www.damnvulnerabledefi.xyz/challenges/side-entrance/)   | ...  | [BILIBILI](https://www.bilibili.com/list/3493272831920239?desc=0&sid=3695249&bvid=BV11w411678R)                                                                                                         | ...  |
| ✅ [5.The Rewarder](https://www.damnvulnerabledefi.xyz/challenges/the-rewarder/)     | ...  | [BILIBILI](https://www.bilibili.com/list/3493272831920239?desc=0&sid=3695249&bvid=BV1QN411s7bj)                                                                                                         | ...  |
| ✅ [6.Selfie](https://www.damnvulnerabledefi.xyz/challenges/selfie/)                 | ...  | [BILIBILI](https://www.bilibili.com/list/3493272831920239?desc=0&sid=3695249&bvid=BV1cN4y1C7Ly)                                                                                                         | ...  |
| ✅ [7.Compromised](https://www.damnvulnerabledefi.xyz/challenges/compromised/)       | ...  | [BILIBILI](https://www.bilibili.com/list/3493272831920239?desc=0&sid=3695249&bvid=BV1vu4y1p7nH)                                                                                                         | ...  |
| ✅ [8.Puppet](https://www.damnvulnerabledefi.xyz/challenges/puppet/)                 | ...  | [BILIBILI](https://www.bilibili.com/list/3493272831920239?desc=0&sid=3695249&bvid=BV1XC4y1G7tj)                                                                                                         | ...  |
| ✅ [9.Puppet V2](https://www.damnvulnerabledefi.xyz/challenges/puppet-v2/)           | ...  | [BILIBILI](https://www.bilibili.com/list/3493272831920239?desc=0&sid=3695249&bvid=BV1784y1d7X3)                                                                                                         | ...  |
| ✅ [10.Free Rider](https://www.damnvulnerabledefi.xyz/challenges/free-rider/)        | ...  | [BILIBILI](https://www.bilibili.com/video/BV1784y1d7X3)                                                                                                                                                 | ...  |
| [11.Backdoor]()                                                                      | ...  | ...                                                                                                                                                                                                     | ...  |
| [12.Climber]()                                                                       | ...  | ...                                                                                                                                                                                                     | ...  |
| [13.Wallet Mining]()                                                                 | ...  | ...                                                                                                                                                                                                     | ...  |
| [14.Puppet V3]()                                                                     | ...  | ...                                                                                                                                                                                                     | ...  |
| [15.ABI Smuggling]()                                                                 | ...  | ...                                                                                                                                                                                                     | ...  |

## [Ethernaut](https://ethernaut.openzeppelin.com/)

[Ethernaut](https://ethernaut.openzeppelin.com/) is a Web3 / Solidity based adversarial game inspired by
overthewire.org, running on the Ethernaut virtual machine. Each level is a smart contract that needs to be hacked.

| Level                                                                                                       | Docs       | Video                                                                                                            | Note |
| ----------------------------------------------------------------------------------------------------------- | ---------- | ---------------------------------------------------------------------------------------------------------------- | ---- |
| ✅ [0.XXXX]()                                                                                               | [Mirror]() | [YouTube]()、 [BILIBILI]()                                                                                       | ...  |
| ✅ [0.Hello Ethernaut](https://ethernaut.openzeppelin.com/level/0x7E0f53981657345B31C59aC44e9c21631Ce710c7) | [Mirror]() | [YouTube](https://www.youtube.com/watch?v=BE0J7I13CPo) 、[BILIBILI](https://www.bilibili.com/video/BV1GV411w7bk) | ...  |
| [1.Fallback]()                                                                                              | [Mirror]() | [YouTube]()、 [BILIBILI]()                                                                                       | ...  |
| [2.Fallout]()                                                                                               | [Mirror]() | [YouTube]()、 [BILIBILI]()                                                                                       | ...  |
| [3.CoinFlip]()                                                                                              | [Mirror]() | [YouTube]()、 [BILIBILI]()                                                                                       | ...  |
| [4.Telephone]()                                                                                             | [Mirror]() | [YouTube]()、 [BILIBILI]()                                                                                       | ...  |
| [5.Token]()                                                                                                 | [Mirror]() | [YouTube]()、 [BILIBILI]()                                                                                       | ...  |
| [6.Delegate]()                                                                                              | [Mirror]() | [YouTube]()、 [BILIBILI]()                                                                                       | ...  |
| [7.Force]()                                                                                                 | [Mirror]() | [YouTube]()、 [BILIBILI]()                                                                                       | ...  |
| [8.Vault]()                                                                                                 | [Mirror]() | [YouTube]()、 [BILIBILI]()                                                                                       | ...  |
| [9.King]()                                                                                                  | [Mirror]() | [YouTube]()、 [BILIBILI]()                                                                                       | ...  |
| [10.Reentrance]()                                                                                           | [Mirror]() | [YouTube]()、 [BILIBILI]()                                                                                       | ...  |

## [ONLYPWNER CTF](https://onlypwner.xyz)

ELEVATE YOUR EVM EXPERTISE WITH HANDS-ON CHALLENGES, COMPETE ON THE LEADERBOARD, AND JOIN A COMMUNITY OF SECURITY
RESEARCHERS AND ENTHUSIASTS.

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

## Hacking Analysis

Provide some Web3 Hack event analysis backtracking.

| Hack                                                                                              |                                                                                                                               Victim                                                                                                                                |                                                     Video                                                      |          Note           |
| :------------------------------------------------------------------------------------------------ | :-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------: | :------------------------------------------------------------------------------------------------------------: | :---------------------: |
| [20231012 - Platypus](https://mirror.xyz/leekdev.eth/RYeKmdl1rkds5IwKTw2Wnr8zLzEDug02xseUZ_wMwvA) | [Victim contract](https://snowtrace.io/address/0x4658EA7e9960D6158a261104aAA160cC953bb6ba),[Exploit transaction](https://snowtrace.io/tx/0xab5f6242fb073af1bb3cd6e891bc93d247e748a69e599a3744ff070447acb20f),[Exploit Code](./contracts/Hack/20231012-Platypus.sol) | [BILIBILI](https://www.bilibili.com/video/BV14u4y1E7nk),[YouTube](https://www.youtube.com/watch?v=THp4budcfpc) | 2.2 Million USD Stolen. |
