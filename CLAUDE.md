# CLAUDE.md

## Project Overview

A Foundry-based Solidity project containing CTF challenges (Ethernaut, Damn Vulnerable DeFi, ONLYPWNER), hack
reproductions, and utility contracts.

## Tech Stack

- **Solidity** (0.8.34, EVM target: osaka)
- **Foundry** (forge, cast, anvil) with Soldeer for dependency management
- **Node.js** dependencies managed via Yarn 4 (yarn@4.13.0)

## Project Structure

- `contracts/` — Solidity source files
- `foundry/test/` — Forge tests
- `foundry/script/` — Forge scripts
- `foundry/out/` — Build artifacts (gitignored)
- `dependencies/` — Soldeer-managed dependencies (gitignored)
- `node_modules/` — npm dependencies (gitignored)

## Build & Test

```bash
forge build          # Compile contracts
forge test           # Run all tests
forge test --mc <ContractName> -vvv  # Run specific test with verbosity
forge fmt            # Format Solidity files
forge coverage       # Generate coverage report
```

## Lint

```bash
bun run lint         # Run solhint + prettier checks
bun run prettier:write  # Auto-fix formatting
```

## Code Conventions

- Solidity formatting follows `foundry.toml` [fmt] section: 4-space tabs, 120 char line length, bracket spacing enabled
- Use `@contracts` remapping to import from `contracts/`
- Use `@dev/forge-std/` for forge-std imports

## Security Rules

- **NEVER read, display, or access `.env` files.** The `.env` file contains private keys, API keys, and other secrets.
  Treat all `.env*` files (except `.env.example`) as strictly off-limits.
- Do not log, print, or embed any secret values (private keys, mnemonics, API keys) in code, tests, or output.
