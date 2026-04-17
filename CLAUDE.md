# CLAUDE.md

## Project Overview

A Foundry-based Solidity project for Web3 security research and learning, containing:

- **CTF challenges** — Ethernaut, Damn Vulnerable DeFi, ONLYPWNER.
- **Hack reproductions** — postmortem re-enactments of real-world exploits (e.g. Platypus 2023-10-12, wkeyDAO
  2025-03-14).
- **Utility contracts & interfaces** — e.g. `BatchTransfer`, `IPancakeRouter`.
- **TypeScript helpers** — key-pair / mnemonic tools, cached ABIs, and ad-hoc scripts.

## Tech Stack

- **Solidity** `0.8.34`, `evm_version = "osaka"`, optimizer on (`runs = 10_000`).
- **Foundry** (`forge`, `cast`, `anvil`) as the primary toolchain. Soldeer is enabled but currently only used for
  `@openzeppelin/contracts-upgradeable` under `dependencies/`.
- **Node dependencies** installed via **Bun** (see `bun.lock` and CI). `package.json` declares
  `"packageManager": "yarn@1.22.22"` for historical reasons, but day-to-day scripts run through `bun run ...`.
- **TypeScript** (ES2021, CommonJS) with `viem` / `ethers` / `web3` for off-chain helpers.

## Project Structure

```
contracts/
├── CTF/
│   ├── Damn-Vulnerable-DeFi/   # 15 levels + 00.Base/ (DVT, DVNFT, Snapshot, WETH9)
│   ├── Ethernaut/              # Level base + 01 Fallback, 02 Fallout, 30–33
│   └── ONLYPWNER/              # 12 challenges, incl. 11.DIVERSION/ subsystem
├── DeFi/                       # placeholder (.gitkeep)
├── Hack/                       # real-exploit reproductions (Platypus, wkeyDAO, …)
├── Interface/Pancake/          # external protocol interfaces (IPancakeRouter, …)
└── Tool/Batch/                 # utility contracts (BatchTransfer)

foundry/
├── test/                       # forge tests, mirroring contracts/ layout
├── script/                     # forge deploy / exploit scripts
├── out/ · cache/ · broadcast/  # build + run artifacts (gitignored)

ts/                             # TypeScript helpers (KeyPair, Tool/Batch, cached ABIs)
hardhat/                        # placeholder only (.gitkeep)
dependencies/                   # Soldeer-managed (gitignored)
node_modules/                   # Bun/npm-managed (gitignored)
.github/workflows/ci.yml        # lint → build → test pipeline
```

Source counts at the time of writing: 53 contracts under `contracts/`, 23 forge tests, 9 forge scripts.

## Foundry Configuration Highlights

- `src = contracts`, `test = foundry/test`, `script = foundry/script`, `libs = ["dependencies"]`.
- Default fuzz `runs = 1_000`; `profile.ci` bumps fuzz to `10_000` with `verbosity = 4`.
- Deterministic `block_timestamp = 1_680_220_800` (2023-03-31 UTC) for reproducible tests.
- `gas_reports = ["*"]`, `bytecode_hash = "none"`, `cbor_metadata = false`.

### Remappings

- `@contracts` → `contracts/`
- `@dev/forge-std/` → `node_modules/forge-std/src`
- `@solmate`, `@solady`, `@prb/test`, `@aave/core-v3`, `@gnosis.pm/safe-contracts`
- `@openzeppelin/contracts` + pinned legacy forks (`-v4.7.3`, `-upgradeable`, `-upgradeable-v4.7.3`)
- `@uniswap/v2-core`, `@uniswap/v2-periphery`, `@uniswap/v3-core`, `@uniswap/v3-periphery`

## Build & Test

```bash
forge build                            # compile contracts
forge build --sizes                    # compile + print contract sizes (used in CI)
forge test                             # run all tests
forge test --mc <ContractName> -vvv    # run a specific test with verbosity
forge test --match-path <path> -vvvvv  # run a single test file
forge coverage                         # generate coverage report
forge fmt                              # format Solidity files
```

## Lint

```bash
bun run lint            # forge fmt --check + solhint + prettier --check
bun run prettier:write  # auto-fix JSON / MD / YML formatting
```

- `foundry.toml [lint]` and `.solhintignore` intentionally skip `contracts/CTF/Damn-Vulnerable-DeFi/**` and
  `contracts/CTF/ONLYPWNER/**` — their vulnerabilities are by design and would drown the lint output in false positives.
- `prettier` targets `**/*.{json,md,yml}` with `printWidth = 120` and `proseWrap = "always"`.

## CI (`.github/workflows/ci.yml`)

Three sequential jobs on `ubuntu-latest` with `FOUNDRY_PROFILE=ci`:

1. **lint** — `bun install` → `bun run lint`
2. **build** — `forge build --sizes`
3. **test** — seeds `FOUNDRY_FUZZ_SEED` weekly (to keep RPC allowance stable), then `forge test`

## Code Conventions

- Solidity formatting per `foundry.toml [fmt]`: 4-space tabs, 120-char lines, double quotes, `long` int types,
  `number_underscore = "thousands"`, `multiline_func_header = "all"`, `wrap_comments = true`.
- Import from `contracts/` via `@contracts/...`; use `@dev/forge-std/` for forge-std.
- Prefer the existing remappings over relative paths for third-party libraries.
- `.editorconfig`: LF line endings, UTF-8, 2-space default, **4-space for `*.sol`**, 1-space for `*.tree`.

## Security Rules

- **NEVER read, display, or access `.env` files.** The `.env` file contains private keys, API keys, and other secrets.
  Treat all `.env*` files (except `.env.example`) as strictly off-limits.
- Do not log, print, or embed any secret values (private keys, mnemonics, API keys) in code, tests, or output.
- Hack reproductions under `contracts/Hack/` and CTF solutions are for educational use only — do not deploy them to
  mainnet.
