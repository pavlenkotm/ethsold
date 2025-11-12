# 🔷 Ink! Smart Contracts for Polkadot/Substrate

Production-ready Ink! smart contracts for Polkadot parachains and Substrate-based blockchains.

## 📋 Overview

Ink! is Rust-based eDSL for writing smart contracts for blockchains built on Substrate, including Polkadot parachains like Astar, Moonbeam, and others.

### Contracts Included

1. **Counter Contract** - Feature-rich counter with events and access control
2. **ERC-20 Token** - Standard fungible token (PSP22 compatible)

---

## 🚀 Prerequisites

### Install Rust and Cargo

```bash
# Install Rust
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh

# Add wasm target
rustup target add wasm32-unknown-unknown

# Verify installation
rustc --version
cargo --version
```

### Install cargo-contract

```bash
# Install cargo-contract (Ink! CLI)
cargo install cargo-contract --force

# Verify installation
cargo contract --version
```

### Install Substrate Contracts Node (for testing)

```bash
# Download substrate-contracts-node
cargo install contracts-node --git https://github.com/paritytech/substrate-contracts-node.git

# Verify installation
substrate-contracts-node --version
```

---

## 📦 Project Structure

```
ink/polkadot-contract/
├── lib.rs                 # Counter contract
├── erc20.rs              # ERC-20 token contract
├── Cargo.toml            # Project dependencies
└── README.md             # This file
```

---

## 🛠️ Setup

### Initialize New Ink! Project

```bash
cd ink/polkadot-contract
cargo contract new my_contract
```

---

## 🔨 Build

### Build All Contracts

```bash
# Build counter contract
cargo contract build --manifest-path Cargo.toml

# Build ERC-20 contract
cargo contract build --release
```

Output files:
- `target/ink/polkadot_contract.wasm` - WebAssembly binary
- `target/ink/polkadot_contract.json` - Contract metadata

---

## 🧪 Testing

### Run Unit Tests

```bash
# Test counter contract
cargo test

# Test with output
cargo test -- --nocapture

# Test specific function
cargo test increment_works
```

### Run Integration Tests

```bash
# Build and run E2E tests
cargo contract test
```

---

## 🚀 Deployment

### 1. Start Local Node

```bash
# Start substrate-contracts-node
substrate-contracts-node --dev --tmp
```

### 2. Deploy Contract via CLI

```bash
# Upload contract code
cargo contract upload --suri //Alice

# Instantiate contract
cargo contract instantiate \
  --constructor new \
  --args 0 \
  --suri //Alice

# Save contract address from output
```

### 3. Interact with Contract

```bash
# Call read-only function
cargo contract call \
  --contract <CONTRACT_ADDRESS> \
  --message get \
  --suri //Alice \
  --dry-run

# Call state-changing function
cargo contract call \
  --contract <CONTRACT_ADDRESS> \
  --message increment \
  --suri //Alice
```

---

## 🌐 Deploy to Testnet/Mainnet

### Astar Network (Shibuya Testnet)

```bash
# Upload to Shibuya testnet
cargo contract upload \
  --url wss://shibuya-rpc.dwellir.com \
  --suri "your mnemonic phrase"

# Instantiate on Shibuya
cargo contract instantiate \
  --constructor new \
  --args 0 \
  --url wss://shibuya-rpc.dwellir.com \
  --suri "your mnemonic phrase"
```

### Polkadot.js UI

1. Go to https://contracts-ui.substrate.io/
2. Connect to your network
3. Upload `polkadot_contract.contract` file
4. Deploy and interact through UI

---

## 📚 Contract Details

### Counter Contract

**Features:**
- Initialize with custom value
- Increment/decrement with overflow protection
- Owner-only reset
- Track per-user increment counts
- Event emissions
- Comprehensive error handling

**Messages:**
```rust
pub fn increment(&mut self) -> Result<()>
pub fn decrement(&mut self) -> Result<()>
pub fn get(&self) -> i32
pub fn reset(&mut self) -> Result<()>
pub fn get_owner(&self) -> AccountId
pub fn get_user_increments(&self, user: AccountId) -> u32
```

### ERC-20 Token Contract

**Features:**
- Standard ERC-20/PSP22 interface
- Mint/burn capabilities
- Allowance system
- Owner-based minting
- Full event emissions

**Messages:**
```rust
pub fn name(&self) -> String
pub fn symbol(&self) -> String
pub fn decimals(&self) -> u8
pub fn total_supply(&self) -> Balance
pub fn balance_of(&self, owner: AccountId) -> Balance
pub fn transfer(&mut self, to: AccountId, value: Balance) -> Result<()>
pub fn approve(&mut self, spender: AccountId, value: Balance) -> Result<()>
pub fn transfer_from(&mut self, from: AccountId, to: AccountId, value: Balance) -> Result<()>
pub fn mint(&mut self, to: AccountId, value: Balance) -> Result<()>
pub fn burn(&mut self, value: Balance) -> Result<()>
```

---

## 🔒 Security Features

- ✅ Overflow/underflow checks (Rust built-in)
- ✅ Access control with owner pattern
- ✅ Safe arithmetic operations
- ✅ Result-based error handling
- ✅ Zero-address protection
- ✅ Comprehensive testing

---

## 🔧 Development Tools

### Polkadot.js Extension
- Browser wallet for testing
- https://polkadot.js.org/extension/

### Contracts UI
- Web-based contract interaction
- https://contracts-ui.substrate.io/

### Cargo Contract Commands

```bash
# Create new contract
cargo contract new <name>

# Build contract
cargo contract build

# Run tests
cargo contract test

# Upload contract
cargo contract upload

# Instantiate contract
cargo contract instantiate

# Call contract
cargo contract call

# Check contract info
cargo contract info
```

---

## 📊 Gas Optimization

- Use appropriate storage types (Mapping vs Vec)
- Minimize storage reads/writes
- Use lazy loading where possible
- Batch operations when feasible
- Profile with `--profile release`

---

## 🌐 Compatible Networks

- **Astar Network** (Polkadot parachain)
- **Shiden Network** (Kusama parachain)
- **Aleph Zero** (Privacy-focused L1)
- **Phala Network** (Confidential contracts)
- **Moonbeam** (EVM + WASM)
- Any Substrate chain with `pallet-contracts`

---

## 📖 Resources

- [Ink! Documentation](https://use.ink/)
- [Ink! Examples](https://github.com/paritytech/ink-examples)
- [Substrate Docs](https://docs.substrate.io/)
- [Polkadot Wiki](https://wiki.polkadot.network/)
- [OpenBrush Library](https://openbrush.io/) - Reusable Ink! components
- [Awesome Ink!](https://github.com/paritytech/awesome-ink)

---

## 🧪 Testing Best Practices

```rust
#[cfg(test)]
mod tests {
    use super::*;

    #[ink::test]
    fn test_name() {
        // Setup
        let mut contract = Counter::new(0);

        // Execute
        assert!(contract.increment().is_ok());

        // Verify
        assert_eq!(contract.get(), 1);
    }

    #[ink::test]
    fn test_events() {
        let mut contract = Counter::new(0);
        contract.increment();

        // Check emitted events
        let emitted = ink::env::test::recorded_events();
        assert_eq!(emitted.count(), 1);
    }
}
```

---

## 🤝 Contributing

Contributions are welcome! Please ensure:
- Code compiles with latest Ink! version
- All tests pass
- Follow Rust conventions
- Add tests for new functionality

---

## 📝 License

MIT License - See LICENSE file for details

---

## 🔗 Related Projects

- [Solidity Contracts](../../solidity/)
- [Cairo Contracts](../../cairo/starknet-contract/)
- [Move Contracts](../../move/aptos/)

---

**Built for Polkadot ecosystem with ❤️**
