# 🐍 Vyper Smart Contracts

Vyper is a pythonic smart contract programming language for the Ethereum Virtual Machine (EVM). It prioritizes security, simplicity, and auditability.

## 📋 Overview

This folder contains Vyper smart contract examples demonstrating:
- **ERC20Token.vy** - A complete ERC-20 token implementation in Vyper

## 🔑 Key Features of Vyper

- **Pythonic Syntax** - Easy to read and write for Python developers
- **Security First** - No class inheritance, no inline assembly, no function/operator overloading
- **Auditable** - Designed to make code easier to audit
- **Bounds & Overflow Checking** - Built-in safety features

## 🚀 Quick Start

### Prerequisites

- Python >= 3.10
- vyper >= 0.3.10

### Installation

```bash
pip install vyper
```

### Compile Contract

```bash
vyper vyper/ERC20Token.vy
```

### Compile with ABI and Bytecode

```bash
vyper -f abi,bytecode vyper/ERC20Token.vy
```

### Generate ABI

```bash
vyper -f abi vyper/ERC20Token.vy > ERC20Token_abi.json
```

## 📄 ERC20Token.vy Details

### Features
- Standard ERC-20 interface implementation
- Mint new tokens (owner only)
- Burn tokens
- Transfer with allowance mechanism
- Event logging for all operations

### Constructor Parameters
- `_name`: Token name (e.g., "VyperToken")
- `_symbol`: Token symbol (e.g., "VYP")
- `_decimals`: Number of decimals (typically 18)
- `_supply`: Initial supply (will be multiplied by 10^decimals)

### Example Deployment

```python
# Using Web3.py
from web3 import Web3
from vyper import compile_code

# Read contract source
with open('ERC20Token.vy', 'r') as f:
    source_code = f.read()

# Compile
compiled = compile_code(source_code, ['abi', 'bytecode'])

# Deploy
w3 = Web3(Web3.HTTPProvider('http://localhost:8545'))
contract = w3.eth.contract(
    abi=compiled['abi'],
    bytecode=compiled['bytecode']
)

# Constructor arguments
tx_hash = contract.constructor(
    "VyperToken",  # name
    "VYP",         # symbol
    18,            # decimals
    1000000        # supply (1M tokens)
).transact()
```

## 🔒 Security Advantages

Vyper enforces security by design:
- No recursive calls
- No infinite loops
- No integer modulo operation
- Enforced decimal typing
- Bounds checking on arrays
- No dynamic arrays in memory

## 📚 Resources

- [Vyper Documentation](https://docs.vyperlang.org/)
- [Vyper by Example](https://vyper-by-example.org/)
- [Vyper GitHub](https://github.com/vyperlang/vyper)
- [ERC-20 Token Standard](https://eips.ethereum.org/EIPS/eip-20)

## 🧪 Testing

```bash
# Install testing dependencies
pip install pytest web3 eth-tester

# Run tests (if test file exists)
pytest test_erc20.py
```

## 📝 License

MIT License
