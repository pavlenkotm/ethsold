# 🔺 Cairo Smart Contracts for StarkNet

Production-ready Cairo smart contracts for StarkNet L2 blockchain.

## 📋 Overview

Cairo is a programming language designed for writing provable programs for StarkNet, a Layer 2 scaling solution for Ethereum using ZK-rollups.

### Contracts Included

1. **Counter Contract** - Simple counter with increment/decrement operations
2. **ERC-20 Token** - Standard fungible token implementation

---

## 🚀 Prerequisites

### Install Cairo and Scarb

```bash
# Install Scarb (Cairo package manager)
curl --proto '=https' --tlsv1.2 -sSf https://docs.swmansion.com/scarb/install.sh | sh

# Verify installation
scarb --version
cairo-compile --version
```

### Install Starkli (StarkNet CLI)

```bash
# Install starkli
curl https://get.starkli.sh | sh
starkliup

# Verify installation
starkli --version
```

---

## 📦 Project Structure

```
cairo/starknet-contract/
├── counter.cairo           # Simple counter contract
├── erc20.cairo            # ERC-20 token implementation
├── Scarb.toml             # Project configuration
└── README.md              # This file
```

---

## 🛠️ Setup

### Initialize Scarb Project

```bash
cd cairo/starknet-contract
scarb init
```

### Configure Scarb.toml

```toml
[package]
name = "starknet_contracts"
version = "0.1.0"
edition = "2023_01"

[dependencies]
starknet = "2.5.0"

[[target.starknet-contract]]
sierra = true
```

---

## 🔨 Compilation

### Compile All Contracts

```bash
scarb build
```

### Compile Specific Contract

```bash
cairo-compile counter.cairo --output counter_compiled.json
cairo-compile erc20.cairo --output erc20_compiled.json
```

---

## 🧪 Testing

### Write Tests (test_counter.cairo)

```cairo
#[cfg(test)]
mod tests {
    use super::Counter;

    #[test]
    fn test_increment() {
        let mut state = Counter::contract_state_for_testing();
        Counter::constructor(ref state, 0);

        Counter::increment(ref state);
        assert(Counter::get_counter(@state) == 1, 'Counter should be 1');
    }
}
```

### Run Tests

```bash
scarb test
```

---

## 🚀 Deployment

### 1. Setup StarkNet Account

```bash
# Create account
starkli account fetch <ADDRESS> --output ~/.starkli-wallets/account.json

# Create signer
starkli signer keystore from-key ~/.starkli-wallets/keystore.json
```

### 2. Declare Contract

```bash
# Declare counter contract
starkli declare target/dev/counter.sierra.json \
  --account ~/.starkli-wallets/account.json \
  --keystore ~/.starkli-wallets/keystore.json \
  --network goerli

# Save the class hash from output
```

### 3. Deploy Contract

```bash
# Deploy counter with initial value 0
starkli deploy <CLASS_HASH> 0 \
  --account ~/.starkli-wallets/account.json \
  --keystore ~/.starkli-wallets/keystore.json \
  --network goerli
```

### 4. Interact with Contract

```bash
# Read counter value
starkli call <CONTRACT_ADDRESS> get_counter --network goerli

# Increment counter
starkli invoke <CONTRACT_ADDRESS> increment \
  --account ~/.starkli-wallets/account.json \
  --keystore ~/.starkli-wallets/keystore.json \
  --network goerli
```

---

## 📚 Contract Details

### Counter Contract

**Features:**
- Initialize with custom value
- Increment/decrement operations
- Owner-only reset functionality
- Event emissions
- Access control

**Functions:**
```cairo
fn increment(ref self: ContractState)
fn decrement(ref self: ContractState)
fn get_counter(self: @ContractState) -> u128
fn reset(ref self: ContractState)
fn get_owner(self: @ContractState) -> ContractAddress
```

### ERC-20 Token Contract

**Features:**
- Standard ERC-20 interface
- Mint/burn capabilities
- Owner-based access control
- Full allowance system
- Transfer events

**Functions:**
```cairo
fn name(self: @ContractState) -> felt252
fn symbol(self: @ContractState) -> felt252
fn decimals(self: @ContractState) -> u8
fn total_supply(self: @ContractState) -> u256
fn balance_of(self: @ContractState, account: ContractAddress) -> u256
fn transfer(ref self: ContractState, recipient: ContractAddress, amount: u256) -> bool
fn approve(ref self: ContractState, spender: ContractAddress, amount: u256) -> bool
fn transfer_from(ref self: ContractState, sender: ContractAddress, recipient: ContractAddress, amount: u256) -> bool
fn mint(ref self: ContractState, to: ContractAddress, amount: u256)
fn burn(ref self: ContractState, amount: u256)
```

---

## 🔒 Security Features

- ✅ Zero address checks
- ✅ Overflow/underflow protection (built-in u256/u128)
- ✅ Access control mechanisms
- ✅ Assertion-based validations
- ✅ Event emissions for transparency

---

## 🌐 Networks

### Testnet (Goerli)
```bash
--network goerli
```

### Mainnet
```bash
--network mainnet
```

---

## 📖 Resources

- [Cairo Book](https://book.cairo-lang.org/)
- [StarkNet Documentation](https://docs.starknet.io/)
- [Scarb Documentation](https://docs.swmansion.com/scarb/)
- [Starkli CLI](https://github.com/xJonathanLEI/starkli)
- [Cairo by Example](https://cairo-by-example.com/)

---

## 🔧 Development Tools

- **Scarb** - Cairo package manager and build tool
- **Starkli** - StarkNet CLI for deployment and interaction
- **Cairo Profiler** - Performance analysis
- **VSCode Cairo Extension** - Syntax highlighting and IntelliSense

---

## 📊 Gas Optimization

Cairo automatically optimizes gas through:
- Efficient field arithmetic
- Optimized memory layout
- Proof generation optimization
- Built-in safety checks

---

## 🤝 Contributing

Contributions are welcome! Please ensure:
- Code follows Cairo best practices
- All tests pass
- Documentation is updated
- Security considerations are addressed

---

## 📝 License

MIT License - See LICENSE file for details

---

## 🔗 Related

- [Solidity Contracts](../../solidity/)
- [Vyper Contracts](../../vyper/)
- [Move Contracts](../../move/aptos/)

---

**Built for StarkNet with ❤️**
