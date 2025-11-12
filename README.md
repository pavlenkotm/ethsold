# 🌐 Web3 Multi-Language Playground

[![Languages](https://img.shields.io/badge/Languages-28+-blue.svg)](https://github.com/pavlenkotm/ethsold)
[![Smart Contracts](https://img.shields.io/badge/Smart_Contracts-15+-green.svg)](./solidity)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](./LICENSE)
[![PRs Welcome](https://img.shields.io/badge/PRs-welcome-brightgreen.svg)](./CONTRIBUTING.md)
[![Commits](https://img.shields.io/github/commit-activity/m/pavlenkotm/ethsold)](https://github.com/pavlenkotm/ethsold/commits)

> **A comprehensive showcase of Web3 development across 28+ programming languages and blockchain platforms, including exotic languages like Zig, Elixir, Kotlin, Scala, Nim, Crystal, and Lua.**

Explore production-ready examples, smart contracts, DApps, and tooling for Ethereum, Solana, Aptos, Cardano, StarkNet, Polkadot, Stacks, NEAR, Internet Computer, Cosmos, and more. Perfect for developers learning blockchain development or showcasing multi-language expertise.

---

## 🎯 Overview

This repository demonstrates Web3 development expertise across the entire blockchain ecosystem:

- **28+ Programming Languages** - From Solidity to exotic languages like Zig, Elixir, Nim
- **10+ Blockchain Platforms** - Ethereum, Solana, Aptos, Cardano, StarkNet, Polkadot, Stacks, NEAR, Internet Computer, Cosmos
- **50+ Meaningful Commits** - Real development history
- **Production-Ready Code** - Security best practices included
- **Comprehensive Documentation** - Each project has detailed README
- **CI/CD Integration** - GitHub Actions workflows
- **Exotic Languages** - Including Zig, Elixir, Kotlin, Scala, Nim, Crystal, Lua

---

## 📋 Languages & Technologies

### Smart Contract Languages

| Language | Platform | Description | Location |
|----------|----------|-------------|----------|
| **🔷 Solidity** | Ethereum (EVM) | 10 production-ready contracts (ERC-20, ERC-721, DeFi) | [📁 solidity/](./solidity) |
| **🐍 Vyper** | Ethereum (EVM) | Pythonic EVM contracts with enhanced security | [📁 vyper/](./vyper) |
| **🦀 Rust** | Solana, NEAR | Anchor framework programs + NEAR Protocol contracts | [📁 rust/solana-program/](./rust/solana-program) [📁 rust/near-contract/](./rust/near-contract) |
| **🚀 Move** | Aptos, Sui | Resource-oriented smart contracts | [📁 move/aptos/](./move/aptos) |
| **🎩 Haskell** | Cardano | Plutus validators and minting policies | [📁 haskell/plutus-cardano/](./haskell/plutus-cardano) |
| **🔺 Cairo** | StarkNet | ZK-rollup smart contracts with provable computation | [📁 cairo/starknet-contract/](./cairo/starknet-contract) |
| **🔷 Ink!** | Polkadot/Substrate | Rust-based eDSL for parachains and Substrate chains | [📁 ink/polkadot-contract/](./ink/polkadot-contract) |
| **🟠 Clarity** | Stacks (Bitcoin L2) | Decidable smart contracts on Bitcoin | [📁 clarity/stacks-contract/](./clarity/stacks-contract) |
| **🌐 Motoko** | Internet Computer | Actor-based language for ICP canisters | [📁 motoko/icp-canister/](./motoko/icp-canister) |
| **🌌 Go** | Cosmos SDK | Custom modules for Cosmos blockchain | [📁 go/cosmos-module/](./go/cosmos-module) |

### Application & Tooling Languages

| Language | Use Case | Description | Location |
|----------|----------|-------------|----------|
| **⚛️ TypeScript** | DApp Frontend | React + Wagmi v2 + Viem | [📁 typescript/dapp-frontend/](./typescript/dapp-frontend) |
| **🐍 Python** | CLI Tools | Web3.py wallet manager & contract deployer | [📁 python/web3-cli/](./python/web3-cli) |
| **🔷 Go** | RPC Client | go-ethereum integration | [📁 go/rpc-client/](./go/rpc-client) |
| **⚡ C++** | Crypto Algorithms | Keccak-256, Merkle Trees, ECDSA | [📁 cpp/crypto-algorithms/](./cpp/crypto-algorithms) |
| **☕ Java** | Enterprise | Web3j SDK integration | [📁 java/web3j-example/](./java/web3j-example) |
| **🍎 Swift** | Mobile | iOS/macOS wallet SDK | [📁 swift/wallet-sdk/](./swift/wallet-sdk) |
| **🐚 Bash** | DevOps | Node deployment & automation | [📁 bash/scripts/](./bash/scripts) |
| **⚡ AssemblyScript** | WASM | High-performance Web3 operations | [📁 assemblyscript/wasm-example/](./assemblyscript/wasm-example) |
| **🌐 HTML/CSS/JS** | Landing Page | Professional project showcase | [📁 frontend/landing-page/](./frontend/landing-page) |

### 🔥 Exotic Languages

| Language | Use Case | Description | Location |
|----------|----------|-------------|----------|
| **⚡ Zig** | Crypto Operations | High-performance Keccak256 & address utilities | [📁 zig/keccak256/](./zig/keccak256) |
| **💧 Elixir** | Blockchain Node | Fault-tolerant node interface with OTP | [📁 elixir/blockchain_node/](./elixir/blockchain_node) |
| **🤖 Kotlin** | Android Wallet | Modern Android wallet with Jetpack Compose | [📁 kotlin/android-wallet/](./kotlin/android-wallet) |
| **🎓 Scala** | Enterprise | Functional blockchain client with Cats Effect | [📁 scala/enterprise-blockchain/](./scala/enterprise-blockchain) |
| **👑 Nim** | Hash Functions | Efficient Keccak256 with Python-like syntax | [📁 nim/keccak_hash/](./nim/keccak_hash) |
| **💎 Crystal** | Blockchain Tools | Ruby-like syntax with C performance | [📁 crystal/blockchain_tools/](./crystal/blockchain_tools) |
| **🌙 Lua** | Smart Contract Scripts | Lightweight scripting for automation | [📁 lua/contract_scripts/](./lua/contract_scripts) |

---

## 🚀 Quick Start

### Clone the Repository

```bash
git clone https://github.com/pavlenkotm/ethsold.git
cd ethsold
```

### Explore Individual Projects

Each sub-directory contains a complete project with its own README:

```bash
# Solidity smart contracts
cd solidity
npm install
npx hardhat compile
npx hardhat test

# TypeScript DApp
cd typescript/dapp-frontend
npm install
npm run dev

# Python Web3 tools
cd python/web3-cli
pip install -r requirements.txt
python wallet_manager.py create

# Go RPC client
cd go/rpc-client
go build
./web3-cli balance 0x...

# And more...
```

---

## 📚 Featured Projects

### 🔷 Solidity Smart Contracts

**10 production-ready contracts** including:
- **Voting System** - Decentralized governance
- **Crowdfunding** - Campaign platform with refunds
- **NFT Marketplace** - ERC-721 with royalties
- **ERC-20 Token** - Standard implementation
- **DAO** - Autonomous organization
- **Staking** - Rewards system
- **Multi-Sig Wallet** - N-of-M signatures
- And more...

[➡️ Explore Solidity](./solidity)

### ⚛️ TypeScript DApp

Modern Web3 frontend with:
- React 18 + TypeScript
- Wagmi v2 hooks
- Viem (lightweight web3 library)
- Multi-wallet support (MetaMask, WalletConnect)
- Multi-chain (Ethereum, Polygon, Arbitrum)

[➡️ Explore DApp](./typescript/dapp-frontend)

### 🐍 Python Web3 Tools

CLI utilities for:
- Wallet management
- Transaction sending
- Contract deployment
- Message signing
- Blockchain queries

[➡️ Explore Python Tools](./python/web3-cli)

### 🦀 Rust Solana Program

Anchor framework counter program with:
- Account initialization
- State management
- Authority-based access control
- Overflow protection

[➡️ Explore Rust/Solana](./rust/solana-program)

---

## 🏗️ Project Structure

```
ethsold/
├── solidity/              # Ethereum smart contracts (Hardhat)
├── vyper/                 # Vyper EVM contracts
├── rust/
│   ├── solana-program/    # Solana Anchor programs
│   └── near-contract/     # NEAR Protocol contracts
├── move/                  # Aptos smart contracts
├── cairo/                 # StarkNet Cairo contracts
├── ink/                   # Polkadot/Substrate Ink! contracts
├── clarity/               # Stacks (Bitcoin L2) contracts
├── motoko/                # Internet Computer canisters
├── typescript/            # React DApp with Wagmi
├── python/                # Web3.py CLI tools
├── go/
│   ├── rpc-client/        # Go Ethereum client
│   └── cosmos-module/     # Cosmos SDK modules
├── cpp/                   # Crypto algorithms
├── java/                  # Web3j enterprise integration
├── swift/                 # iOS/macOS wallet SDK
├── bash/                  # Deployment scripts
├── haskell/               # Cardano Plutus contracts
├── assemblyscript/        # WebAssembly modules
├── frontend/              # HTML/CSS/JS landing page
├── zig/                   # Zig Keccak256 implementation
├── elixir/                # Elixir blockchain node
├── kotlin/                # Kotlin Android wallet
├── scala/                 # Scala enterprise blockchain
├── nim/                   # Nim hash functions
├── crystal/               # Crystal blockchain tools
├── lua/                   # Lua smart contract scripts
├── .github/               # CI/CD workflows
├── README.md              # This file
├── CONTRIBUTING.md        # Contribution guidelines
├── CODE_OF_CONDUCT.md     # Code of conduct
└── LICENSE                # MIT License
```

---

## 🧪 Testing

Most projects include tests:

```bash
# Solidity contracts
cd solidity && npx hardhat test

# Python tools
cd python/web3-cli && pytest

# TypeScript DApp
cd typescript/dapp-frontend && npm test

# Go client
cd go/rpc-client && go test ./...
```

---

## 🔧 CI/CD

GitHub Actions workflows for:
- ✅ Automated testing
- 🔍 Linting and formatting
- 🏗️ Build verification
- 📦 Dependency management

See [`.github/workflows/`](./.github/workflows/) for configuration.

---

## 🤝 Contributing

Contributions are welcome! Please read our [Contributing Guidelines](./CONTRIBUTING.md) and [Code of Conduct](./CODE_OF_CONDUCT.md).

### How to Contribute

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'feat: add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

---

## 📊 Repository Stats

- **28+ Programming Languages** covering all major blockchain platforms + exotic languages
- **50+ Meaningful Commits** demonstrating real development activity
- **15+ Smart Contracts** across 10+ blockchain platforms
- **10+ Blockchain Platforms** - Ethereum, Solana, NEAR, Aptos, Cardano, StarkNet, Polkadot, Stacks, Internet Computer, Cosmos
- **Production-Ready** code with security best practices
- **Comprehensive Documentation** for every project
- **7 Exotic Languages** - Zig, Elixir, Kotlin, Scala, Nim, Crystal, Lua

---

## 🎓 Learning Resources

Each sub-project includes:
- 📖 **Detailed README** - Setup, usage, and examples
- 💡 **Code Comments** - Inline explanations
- 🔗 **External Links** - Official documentation and tutorials
- 🧪 **Test Examples** - How to test the code
- 🚀 **Deployment Guides** - Production deployment steps

---

## 🌟 Use Cases

This repository is perfect for:

- **🎯 Learning** - Explore Web3 development in multiple languages
- **💼 Portfolio** - Showcase blockchain expertise to employers
- **🔬 Research** - Compare blockchain platforms and languages
- **🚀 Prototyping** - Use as templates for your projects
- **📚 Education** - Teaching material for blockchain courses

---

## 🔒 Security

- ✅ All contracts include security best practices
- ✅ Reentrancy protection where applicable
- ✅ Access control mechanisms
- ✅ Input validation
- ✅ Overflow/underflow protection
- ⚠️ **Important**: Conduct thorough audits before production use

---

## 📝 License

This project is licensed under the MIT License - see the [LICENSE](./LICENSE) file for details.

---

## 👤 Author

**Pavlenko TM**

- GitHub: [@pavlenkotm](https://github.com/pavlenkotm)
- Repository: [ethsold](https://github.com/pavlenkotm/ethsold)

---

## 🙏 Acknowledgments

- [OpenZeppelin](https://openzeppelin.com/) - Secure smart contract library
- [Hardhat](https://hardhat.org/) - Ethereum development environment
- [Wagmi](https://wagmi.sh/) - React hooks for Ethereum
- [Anchor](https://www.anchor-lang.com/) - Solana framework
- [web3swift](https://github.com/web3swift-team/web3swift) - iOS Web3 library

---

## 🔗 Links

- 📖 [Documentation](https://github.com/pavlenkotm/ethsold#readme)
- 🐛 [Report Issues](https://github.com/pavlenkotm/ethsold/issues)
- 💬 [Discussions](https://github.com/pavlenkotm/ethsold/discussions)
- 🌐 [Landing Page](./frontend/landing-page/index.html)

---

<div align="center">

**⭐ Star this repo if you find it useful! ⭐**

**Built with ❤️ by the Web3 community**

</div>
