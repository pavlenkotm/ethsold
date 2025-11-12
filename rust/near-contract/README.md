# 🔷 NEAR Protocol Smart Contracts (Rust)

Production-ready smart contracts for NEAR Protocol using Rust and near-sdk.

## 📋 Overview

NEAR Protocol is a layer-1 blockchain that uses sharding for scalability. Contracts are written in Rust (or AssemblyScript) and compiled to WebAssembly.

### Contracts Included

1. **Counter Contract** - Feature-rich counter with events, storage, and access control

---

## 🚀 Prerequisites

### Install Rust

```bash
# Install Rust
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh

# Add wasm32 target
rustup target add wasm32-unknown-unknown

# Verify installation
rustc --version
cargo --version
```

### Install NEAR CLI

```bash
# Install NEAR CLI
npm install -g near-cli

# Verify installation
near --version
```

---

## 📦 Project Structure

```
rust/near-contract/
├── src/
│   └── lib.rs            # Counter contract
├── Cargo.toml            # Project dependencies
└── README.md             # This file
```

---

## 🛠️ Setup

### Initialize NEAR Project

```bash
cd rust/near-contract

# Create NEAR account (testnet)
near login
```

---

## 🔨 Build

### Build Contract

```bash
# Build for WASM
cargo build --target wasm32-unknown-unknown --release

# Optimize WASM (optional but recommended)
# Install wasm-opt first: npm install -g wasm-opt
wasm-opt -Oz -o target/wasm32-unknown-unknown/release/near_counter.wasm \
  target/wasm32-unknown-unknown/release/near_counter.wasm
```

### Using NEAR Build Tools

```bash
# Install cargo-near for easier builds
cargo install cargo-near

# Build with cargo-near
cargo near build

# Build with ABI generation
cargo near build --release
```

---

## 🧪 Testing

### Run Unit Tests

```bash
# Run all tests
cargo test

# Run with output
cargo test -- --nocapture

# Run specific test
cargo test test_increment
```

### Integration Testing

```bash
# Using NEAR workspaces (Rust)
# Add to Cargo.toml:
# [dev-dependencies]
# near-workspaces = "0.7.0"
# tokio = { version = "1", features = ["full"] }

# Run integration tests
cargo test --features integration-tests
```

---

## 🚀 Deployment

### 1. Deploy to Testnet

```bash
# Deploy contract
near deploy \
  --accountId YOUR_ACCOUNT.testnet \
  --wasmFile target/wasm32-unknown-unknown/release/near_counter.wasm

# Initialize contract
near call YOUR_ACCOUNT.testnet new '{"initial_value": 0}' \
  --accountId YOUR_ACCOUNT.testnet
```

### 2. Interact with Contract

```bash
# Get counter value
near view YOUR_ACCOUNT.testnet get_counter

# Increment counter
near call YOUR_ACCOUNT.testnet increment \
  --accountId YOUR_ACCOUNT.testnet

# Decrement counter
near call YOUR_ACCOUNT.testnet decrement \
  --accountId YOUR_ACCOUNT.testnet

# Increment by amount
near call YOUR_ACCOUNT.testnet increment_by '{"amount": 5}' \
  --accountId YOUR_ACCOUNT.testnet

# Get user increments
near view YOUR_ACCOUNT.testnet get_user_increments \
  '{"account_id": "YOUR_ACCOUNT.testnet"}'

# Reset counter (owner only)
near call YOUR_ACCOUNT.testnet reset \
  --accountId YOUR_ACCOUNT.testnet

# Get recent events
near view YOUR_ACCOUNT.testnet get_recent_events
```

### 3. Deploy to Mainnet

```bash
# Create mainnet account
near create-account YOUR_ACCOUNT.near --useFaucet

# Deploy to mainnet
near deploy \
  --accountId YOUR_ACCOUNT.near \
  --wasmFile target/wasm32-unknown-unknown/release/near_counter.wasm \
  --networkId mainnet

# Initialize
near call YOUR_ACCOUNT.near new '{"initial_value": 0}' \
  --accountId YOUR_ACCOUNT.near \
  --networkId mainnet
```

---

## 📚 Contract Details

### Counter Contract

**Features:**
- Persistent storage with near-sdk collections
- Owner-based access control
- Event logging with env::log_str
- Per-user increment tracking
- Safe arithmetic with checked operations
- View and call methods

**View Methods (read-only, free):**
```rust
pub fn get_counter(&self) -> i64
pub fn get_owner(&self) -> AccountId
pub fn get_total_increments(&self) -> u64
pub fn get_user_increments(&self, account_id: AccountId) -> u64
pub fn get_recent_events(&self) -> Vec<String>
pub fn get_all_events(&self) -> Vec<String>
```

**Call Methods (state-changing, costs gas):**
```rust
pub fn new(initial_value: i64) -> Self  // Constructor
pub fn increment(&mut self)
pub fn decrement(&mut self)
pub fn increment_by(&mut self, amount: i64)
pub fn reset(&mut self)  // Owner only
pub fn set_counter(&mut self, value: i64)  // Owner only
pub fn clear_events(&mut self)  // Owner only
```

---

## 🔒 Security Features

- ✅ Ownership verification with `assert_owner()`
- ✅ Overflow/underflow protection with `checked_add/sub`
- ✅ State initialization check
- ✅ Borsh serialization for efficient storage
- ✅ Event logging for transparency
- ✅ Unit tests with near-sdk test utilities

---

## 💰 Gas & Storage

### Gas Costs (approximate)
- View methods: **0 NEAR** (free)
- `increment()`: **~0.0003 NEAR**
- `decrement()`: **~0.0003 NEAR**
- `reset()`: **~0.0002 NEAR**

### Storage Costs
- Base contract storage: **~0.1 NEAR**
- Per user increment entry: **~0.0001 NEAR**

---

## 🔧 Development Tools

### NEAR CLI Commands

```bash
# Account management
near login
near create-account sub.account.testnet --masterAccount account.testnet
near state YOUR_ACCOUNT.testnet
near delete YOUR_ACCOUNT.testnet beneficiary.testnet

# Contract interaction
near deploy --accountId ACCOUNT --wasmFile contract.wasm
near call CONTRACT_ID method '{"arg": "value"}' --accountId CALLER
near view CONTRACT_ID method '{"arg": "value"}'

# Keys management
near keys ACCOUNT
near add-key ACCOUNT PUBLIC_KEY
near delete-key ACCOUNT PUBLIC_KEY
```

### NEAR Explorer
- **Testnet**: https://explorer.testnet.near.org/
- **Mainnet**: https://explorer.near.org/

### NEAR Wallet
- **Testnet**: https://wallet.testnet.near.org/
- **Mainnet**: https://wallet.near.org/

---

## 📊 Storage Patterns

### Collections

```rust
use near_sdk::collections::{LookupMap, Vector, UnorderedMap, UnorderedSet};

// Fast lookups, no iteration
pub struct MyContract {
    lookup: LookupMap<AccountId, u64>,
}

// Iterable collection
pub struct MyContract {
    unordered: UnorderedMap<AccountId, u64>,
}

// Ordered list
pub struct MyContract {
    vector: Vector<String>,
}
```

---

## 🌐 Cross-Contract Calls

```rust
use near_sdk::Promise;

#[near_bindgen]
impl Contract {
    pub fn cross_contract_call(&self, account_id: AccountId) -> Promise {
        Promise::new(account_id)
            .function_call(
                "method_name".to_string(),
                json!({"arg": "value"}).to_string().into_bytes(),
                0,                    // attached deposit
                5_000_000_000_000,    // gas
            )
    }
}
```

---

## 📖 Resources

- [NEAR Documentation](https://docs.near.org/)
- [near-sdk-rs Guide](https://www.near-sdk.io/)
- [NEAR Examples](https://github.com/near-examples)
- [NEAR University](https://www.near.university/)
- [NEAR Nomicon](https://nomicon.io/) - Protocol specification
- [NEAR Certified Developer](https://www.near.university/courses/near-certified-developer)

---

## 🧪 Testing Best Practices

```rust
#[cfg(test)]
mod tests {
    use super::*;
    use near_sdk::test_utils::{accounts, VMContextBuilder};
    use near_sdk::testing_env;

    fn get_context(predecessor: AccountId) -> VMContextBuilder {
        let mut builder = VMContextBuilder::new();
        builder
            .predecessor_account_id(predecessor)
            .attached_deposit(0)
            .account_balance(1_000_000_000_000_000_000_000_000);
        builder
    }

    #[test]
    fn test_something() {
        let context = get_context(accounts(0));
        testing_env!(context.build());

        let contract = Counter::new(0);
        // Test logic
    }
}
```

---

## 🔄 Upgrade Strategy

```rust
#[near_bindgen]
#[derive(BorshDeserialize, BorshSerialize)]
pub struct OldContract {
    value: i32,
}

#[near_bindgen]
impl OldContract {
    #[init(ignore_state)]
    pub fn migrate() -> Self {
        let old_state: OldContract = env::state_read().expect("Failed to read state");
        Self {
            value: old_state.value,
            // Initialize new fields
        }
    }
}
```

---

## 🤝 Contributing

Contributions are welcome! Please ensure:
- Code compiles with latest near-sdk
- All tests pass
- Follow Rust best practices
- Add tests for new features

---

## 📝 License

MIT License - See LICENSE file for details

---

## 🔗 Related

- [Rust Solana Program](../solana-program/)
- [Ink! Contracts](../../ink/polkadot-contract/)
- [Move Contracts](../../move/aptos/)

---

**Building on NEAR Protocol with Rust 🦀**
