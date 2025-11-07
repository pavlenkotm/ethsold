# 🚀 Move Smart Contracts - Aptos

Move is a programming language for writing safe smart contracts, originally developed for Diem (Libra) and now used by Aptos and Sui blockchains.

## 📋 Overview

This directory contains Move smart contracts for the Aptos blockchain:
- **simple_token.move** - A fungible token implementation using Aptos coin framework

## 🔑 Key Features of Move

- **Resource-Oriented** - Resources can't be copied or dropped, only moved
- **Safety First** - No dynamic dispatch, formal verification support
- **Linear Types** - Prevents resource duplication and loss
- **Module System** - Clear ownership and access control
- **Generics** - Type-safe generic programming

## 🎯 Simple Token Contract

### Features
- Initialize token with custom metadata (name, symbol, decimals)
- Mint tokens (owner only)
- Burn tokens from any account
- Transfer tokens between accounts
- Query balance and total supply
- Event emission for tracking

### Resource Types

```move
struct SimpleToken has key, store {
    name: String,
    symbol: String,
    decimals: u8,
    total_supply: u64,
}

struct TokenCapabilities has key {
    mint_cap: coin::MintCapability<SimpleToken>,
    burn_cap: coin::BurnCapability<SimpleToken>,
    freeze_cap: coin::FreezeCapability<SimpleToken>,
}
```

## 🚀 Quick Start

### Prerequisites

- Aptos CLI >= 2.0.0
- Move compiler

### Installation

```bash
# Install Aptos CLI
curl -fsSL "https://aptos.dev/scripts/install_cli.py" | python3

# Verify installation
aptos --version
```

### Compile the Module

```bash
cd move/aptos
aptos move compile
```

### Run Tests

```bash
aptos move test
```

### Publish to Devnet

```bash
# Initialize Aptos account (if not done)
aptos init --network devnet

# Publish module
aptos move publish --named-addresses simple_token=default
```

### Interact with the Contract

```bash
# Initialize token
aptos move run \
  --function-id 'default::simple_token::initialize' \
  --args string:"My Token" string:"MTK" u8:8 u64:1000000

# Mint tokens
aptos move run \
  --function-id 'default::simple_token::mint' \
  --args address:0x123... u64:1000

# Check balance
aptos move view \
  --function-id 'default::simple_token::balance_of' \
  --args address:0x123...

# Transfer tokens
aptos move run \
  --function-id 'default::simple_token::transfer' \
  --args address:0x456... u64:100
```

## 📁 Project Structure

```
aptos/
├── Move.toml               # Project configuration
├── sources/
│   └── simple_token.move  # Token implementation
└── tests/                 # Test files (optional)
```

## 🔒 Move Safety Guarantees

### Resource Safety
Move's type system ensures:
- **No copies**: Resources can't be accidentally duplicated
- **No loss**: Resources can't be discarded
- **No forgery**: Resources can't be created from nothing

### Example
```move
struct Token has key {
    value: u64
}

// ❌ Can't copy
let token2 = token1; // token1 is moved, not copied

// ❌ Can't drop
// token is automatically dropped // Compiler error!

// ✅ Must explicitly handle
move_to(account, token); // Proper transfer
```

## 🧪 Testing

Move has built-in unit testing:

```move
#[test(owner = @simple_token)]
public fun test_initialize(owner: &signer) {
    initialize(
        owner,
        b"Test Token",
        b"TEST",
        8,
        1000000
    );
}

#[test(owner = @simple_token, user = @0x123)]
#[expected_failure(abort_code = E_INSUFFICIENT_BALANCE)]
public fun test_insufficient_balance(owner: &signer, user: &signer) {
    burn(user, 1000); // Should fail
}
```

Run tests:
```bash
aptos move test
```

## 📊 Move vs Solidity

| Feature | Move | Solidity |
|---------|------|----------|
| Resource Safety | ✅ Built-in | ❌ Manual |
| Formal Verification | ✅ Designed for | ⚠️ Limited |
| Gas Model | Predictable | Complex |
| Reentrancy | ✅ Prevented by design | ❌ Manual checks |
| Integer Overflow | ✅ Checked | ✅ (since 0.8.0) |

## 📚 Resources

- [Aptos Documentation](https://aptos.dev/)
- [Move Book](https://move-language.github.io/move/)
- [Move Tutorial](https://github.com/aptos-labs/aptos-core/tree/main/aptos-move/move-examples)
- [Aptos CLI Reference](https://aptos.dev/cli-tools/aptos-cli-tool/use-aptos-cli)
- [Move Prover](https://github.com/move-language/move/tree/main/language/move-prover)

## 💡 Advanced Topics

- **Object Model**: Composable NFTs and dynamic resources
- **Tables & Vectors**: Efficient data structures
- **Events**: Off-chain indexing
- **Access Control**: Fine-grained permissions
- **Formal Verification**: Prove contract correctness

## 🎓 Learning Path

1. ✅ Understand resource-oriented programming
2. ✅ Learn Move syntax and semantics
3. 📖 Study Aptos framework modules
4. 🛠️ Build simple token contract
5. 🚀 Create complex DeFi protocols
6. 🔬 Use Move Prover for verification

## 📝 License

MIT License
