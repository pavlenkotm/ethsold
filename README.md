# 🌐 Web3 Multi-Language Playground

[![Languages](https://img.shields.io/badge/Languages-15+-blue.svg)](https://github.com/pavlenkotm/ethsold)
[![Smart Contracts](https://img.shields.io/badge/Smart_Contracts-10+-green.svg)](./solidity)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](./LICENSE)
[![PRs Welcome](https://img.shields.io/badge/PRs-welcome-brightgreen.svg)](./CONTRIBUTING.md)
[![Commits](https://img.shields.io/github/commit-activity/m/pavlenkotm/ethsold)](https://github.com/pavlenkotm/ethsold/commits)

> **A comprehensive showcase of Web3 development across 15+ programming languages and blockchain platforms.**

Explore production-ready examples, smart contracts, DApps, and tooling for Ethereum, Solana, Aptos, Cardano, and more. Perfect for developers learning blockchain development or showcasing multi-language expertise.

---

## 🎯 Overview

This repository demonstrates Web3 development expertise across the entire blockchain ecosystem:

- **15+ Programming Languages** - From Solidity to Haskell
- **5+ Blockchain Platforms** - Ethereum, Solana, Aptos, Cardano, and more
- **40+ Meaningful Commits** - Real development history
- **Production-Ready Code** - Security best practices included
- **Comprehensive Documentation** - Each project has detailed README
- **CI/CD Integration** - GitHub Actions workflows

---

## 📋 Languages & Technologies

### Smart Contract Languages

| Language | Platform | Description | Location |
|----------|----------|-------------|----------|
| **🔷 Solidity** | Ethereum | 10 production-ready contracts (ERC-20, ERC-721, DeFi) | [📁 solidity/](./solidity) |
| **🐍 Vyper** | Ethereum | Pythonic EVM contracts with enhanced security | [📁 vyper/](./vyper) |
| **🦀 Rust** | Solana | Anchor framework programs | [📁 rust/solana-program/](./rust/solana-program) |
| **🚀 Move** | Aptos | Resource-oriented smart contracts | [📁 move/aptos/](./move/aptos) |
| **🎩 Haskell** | Cardano | Plutus validators and minting policies | [📁 haskell/plutus-cardano/](./haskell/plutus-cardano) |

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
├── rust/                  # Solana Anchor programs
├── move/                  # Aptos smart contracts
├── typescript/            # React DApp with Wagmi
├── python/                # Web3.py CLI tools
├── go/                    # Go Ethereum client
├── cpp/                   # Crypto algorithms
├── java/                  # Web3j enterprise integration
├── swift/                 # iOS/macOS wallet SDK
├── bash/                  # Deployment scripts
├── haskell/               # Cardano Plutus contracts
├── assemblyscript/        # WebAssembly modules
├── frontend/              # HTML/CSS/JS landing page
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

- **15+ Programming Languages** covering all major blockchain platforms
- **40+ Meaningful Commits** demonstrating real development activity
- **10+ Smart Contracts** for various use cases
- **Production-Ready** code with security best practices
- **Comprehensive Documentation** for every project

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
