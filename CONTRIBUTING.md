# Contributing to Web3 Multi-Language Playground

First off, thank you for considering contributing to this project! 🎉

This document provides guidelines for contributing to the Web3 Multi-Language Playground repository.

## 📋 Table of Contents

- [Code of Conduct](#code-of-conduct)
- [How Can I Contribute?](#how-can-i-contribute)
- [Development Setup](#development-setup)
- [Coding Standards](#coding-standards)
- [Commit Message Guidelines](#commit-message-guidelines)
- [Pull Request Process](#pull-request-process)

## 📜 Code of Conduct

This project adheres to a Code of Conduct that all contributors are expected to follow. Please read [CODE_OF_CONDUCT.md](./CODE_OF_CONDUCT.md) before contributing.

## 🤝 How Can I Contribute?

### Reporting Bugs

Before creating bug reports, please check existing issues to avoid duplicates. When creating a bug report, include:

- **Clear title and description**
- **Steps to reproduce**
- **Expected vs actual behavior**
- **Environment details** (OS, language version, etc.)
- **Code samples** if applicable

### Suggesting Enhancements

Enhancement suggestions are tracked as GitHub issues. When creating an enhancement suggestion:

- **Use a clear title**
- **Provide detailed description**
- **Explain why this would be useful**
- **Provide examples** if applicable

### Adding New Language Examples

We welcome examples in additional programming languages! To add a new language:

1. Create a new directory: `<language-name>/`
2. Add working code examples
3. Include a comprehensive README.md
4. Add tests if applicable
5. Update the root README.md to include your language

### Improving Documentation

Documentation improvements are always welcome:

- Fix typos or clarify existing docs
- Add more examples
- Improve setup instructions
- Translate documentation

## 🛠️ Development Setup

### Prerequisites

Depending on which part you're contributing to:

- **Solidity**: Node.js 16+, Hardhat
- **Python**: Python 3.10+
- **TypeScript**: Node.js 18+
- **Rust**: Rust 1.70+, Solana CLI
- **Go**: Go 1.21+
- **C++**: GCC/Clang, CMake
- **Java**: Java 17+, Maven
- **Swift**: Xcode 14+

### Setup Steps

1. **Fork the repository**

```bash
# Clone your fork
git clone https://github.com/<your-username>/ethsold.git
cd ethsold
```

2. **Create a branch**

```bash
git checkout -b feature/your-feature-name
```

3. **Install dependencies** (for the language you're working with)

```bash
# Example for Solidity
cd solidity
npm install

# Example for Python
cd python/web3-cli
pip install -r requirements.txt
```

4. **Make your changes**

5. **Test your changes**

```bash
# Run relevant tests
npm test
# or
pytest
# or
go test ./...
```

## 📝 Coding Standards

### General Guidelines

- **Write clear, readable code**
- **Add comments** for complex logic
- **Follow existing code style** in the repository
- **Include error handling**
- **Add tests** for new features

### Language-Specific Standards

#### Solidity
- Use Solidity ^0.8.20
- Follow [Solidity Style Guide](https://docs.soliditylang.org/en/latest/style-guide.html)
- Include NatSpec comments
- Use OpenZeppelin libraries where applicable

#### JavaScript/TypeScript
- Use ES6+ features
- Follow Airbnb style guide
- Use TypeScript strict mode
- Add JSDoc/TSDoc comments

#### Python
- Follow PEP 8
- Use type hints
- Add docstrings
- Use Black for formatting

#### Rust
- Follow Rust style guide
- Use `cargo fmt` and `cargo clippy`
- Add documentation comments

#### Go
- Follow Go conventions
- Use `gofmt` and `golint`
- Add package documentation

## 💬 Commit Message Guidelines

We use [Conventional Commits](https://www.conventionalcommits.org/) format:

```
<type>(<scope>): <subject>

<body>

<footer>
```

### Types

- **feat**: New feature
- **fix**: Bug fix
- **docs**: Documentation changes
- **style**: Code style changes (formatting, etc.)
- **refactor**: Code refactoring
- **test**: Adding or updating tests
- **chore**: Maintenance tasks

### Examples

```bash
feat(solidity): add ERC-721 NFT contract

Implement a complete ERC-721 contract with minting,
burning, and metadata support.

Closes #123

---

fix(python): resolve wallet connection timeout

Update connection retry logic to handle network delays.

---

docs(readme): add Rust examples to main README

Include Solana Anchor framework examples in the
language overview table.
```

## 🔄 Pull Request Process

1. **Update documentation** if needed
2. **Add tests** for new features
3. **Ensure all tests pass**
4. **Update the README.md** with new features/languages
5. **Follow commit message guidelines**
6. **Request review** from maintainers

### PR Checklist

- [ ] Code follows project style guidelines
- [ ] Self-review completed
- [ ] Comments added to complex code
- [ ] Documentation updated
- [ ] Tests added/updated
- [ ] All tests passing
- [ ] No merge conflicts
- [ ] Linked to related issues

### PR Title Format

```
<type>(<scope>): <description>
```

Example:
```
feat(typescript): add Web3Modal integration to DApp
```

## 🧪 Testing

### Running Tests

```bash
# Solidity
cd solidity && npx hardhat test

# Python
cd python/web3-cli && pytest

# TypeScript
cd typescript/dapp-frontend && npm test

# Rust
cd rust/solana-program && cargo test

# Go
cd go/rpc-client && go test ./...
```

### Writing Tests

- Write unit tests for all new functions
- Include edge cases
- Test error handling
- Add integration tests where applicable

## 🎨 Style Guidelines

### File Naming

- Use lowercase with hyphens: `smart-contract.sol`
- Use descriptive names: `wallet-manager.py`

### Directory Structure

```
language-name/
├── src/              # Source code
├── tests/            # Test files
├── README.md         # Project documentation
└── package.json      # Dependencies (if applicable)
```

## 🚀 Deployment

When adding deployment scripts:

- Test on testnets first
- Include clear instructions
- Add safety checks
- Document gas costs

## 📚 Resources

- [Ethereum Development](https://ethereum.org/en/developers/)
- [Solidity Docs](https://docs.soliditylang.org/)
- [web3.js](https://web3js.readthedocs.io/)
- [Hardhat](https://hardhat.org/getting-started/)
- [Anchor](https://book.anchor-lang.com/)

## 💡 Questions?

If you have questions:

- Check existing [Issues](https://github.com/pavlenkotm/ethsold/issues)
- Open a new [Discussion](https://github.com/pavlenkotm/ethsold/discussions)
- Contact maintainers

## 🙏 Thank You!

Your contributions make this project better for everyone!

---

**Happy Coding! 🚀**
