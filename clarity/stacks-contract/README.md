# 🟠 Clarity Smart Contracts for Stacks (Bitcoin L2)

Production-ready Clarity smart contracts for Stacks blockchain - Bitcoin Layer 2.

## 📋 Overview

Clarity is a decidable smart contract language that enables contracts on the Stacks blockchain, which settles transactions on Bitcoin. Clarity is designed for predictability and security.

### Contracts Included

1. **Counter Contract** - Feature-rich counter with events and ownership
2. **SIP-010 Token** - Standard fungible token (Stacks Improvement Proposal 010)

---

## 🚀 Prerequisites

### Install Clarinet (Clarity Development Tool)

```bash
# Install Clarinet (macOS/Linux)
curl -L https://github.com/hirosystems/clarinet/releases/latest/download/clarinet-linux-x64.tar.gz | tar xz
sudo mv clarinet /usr/local/bin/

# Or via Homebrew (macOS)
brew install clarinet

# Verify installation
clarinet --version
```

### Install Stacks CLI

```bash
# Install @stacks/cli
npm install -g @stacks/cli

# Verify installation
stx --version
```

---

## 📦 Project Structure

```
clarity/stacks-contract/
├── counter.clar           # Counter contract
├── sip010-token.clar     # SIP-010 fungible token
├── Clarinet.toml         # Project configuration
├── settings/             # Network settings
└── README.md             # This file
```

---

## 🛠️ Setup

### Initialize Clarinet Project

```bash
cd clarity/stacks-contract

# Initialize new project (if needed)
clarinet new stacks-contract

# Check project
clarinet check
```

---

## 🔨 Configuration

### Clarinet.toml

```toml
[project]
name = "stacks-contract"
authors = ["Web3 Developer"]
description = "Clarity smart contracts for Stacks"
telemetry = false

[contracts.counter]
path = "counter.clar"
clarity_version = 2

[contracts.token]
path = "sip010-token.clar"
clarity_version = 2
```

---

## 🧪 Testing

### Write Tests (tests/counter_test.ts)

```typescript
import { Clarinet, Tx, Chain, Account } from 'clarinet';

Clarinet.test({
  name: "Counter increments correctly",
  async fn(chain: Chain, accounts: Map<string, Account>) {
    const deployer = accounts.get('deployer')!;

    let block = chain.mineBlock([
      Tx.contractCall('counter', 'increment', [], deployer.address),
    ]);

    block.receipts[0].result.expectOk().expectUint(1);
  },
});

Clarinet.test({
  name: "Only owner can reset",
  async fn(chain: Chain, accounts: Map<string, Account>) {
    const deployer = accounts.get('deployer')!;
    const wallet1 = accounts.get('wallet_1')!;

    let block = chain.mineBlock([
      Tx.contractCall('counter', 'reset', [], wallet1.address),
    ]);

    block.receipts[0].result.expectErr().expectUint(100);
  },
});
```

### Run Tests

```bash
# Run all tests
clarinet test

# Run specific test file
clarinet test tests/counter_test.ts

# Run with coverage
clarinet test --coverage
```

---

## 🚀 Deployment

### 1. Console Testing (Local)

```bash
# Start Clarinet console
clarinet console

# Deploy and interact in REPL
>> (contract-call? .counter increment)
>> (contract-call? .counter get-counter)
```

### 2. Deploy to Testnet

```bash
# Configure testnet network
clarinet deployments generate --testnet

# Deploy to testnet
clarinet deployments apply -p deployments/default.testnet-plan.yaml
```

### 3. Deploy to Mainnet

```bash
# Generate deployment plan
clarinet deployments generate --mainnet

# Review the plan
cat deployments/default.mainnet-plan.yaml

# Deploy to mainnet
clarinet deployments apply -p deployments/default.mainnet-plan.yaml
```

### 4. Manual Deployment via Stacks CLI

```bash
# Deploy contract
stx deploy_contract counter.clar counter \
  --network testnet \
  --private-key <YOUR_PRIVATE_KEY>
```

---

## 📚 Contract Details

### Counter Contract

**Features:**
- Increment/decrement operations
- Increment by custom amount
- Owner-only reset
- Track per-user increments
- Event logging
- Overflow/underflow protection

**Read-only Functions:**
```clarity
(get-counter)
(get-owner)
(get-total-increments)
(get-user-increments (user principal))
```

**Public Functions:**
```clarity
(increment)
(decrement)
(increment-by (amount uint))
(reset)
(set-counter (value uint))
```

### SIP-010 Token Contract

**Features:**
- SIP-010 standard compliant
- Mint/burn capabilities
- Transfer with memo
- Owner-based minting
- Token URI support
- Event emissions

**SIP-010 Functions:**
```clarity
(transfer (amount uint) (sender principal) (recipient principal) (memo (optional (buff 34))))
(get-name)
(get-symbol)
(get-decimals)
(get-balance (account principal))
(get-total-supply)
(get-token-uri)
```

**Additional Functions:**
```clarity
(mint (amount uint) (recipient principal))
(burn (amount uint))
(set-token-uri (uri (string-utf8 256)))
(get-owner)
```

---

## 🔒 Security Features

- ✅ Decidable language (no recursion, no reentrancy)
- ✅ Static analysis friendly
- ✅ Overflow/underflow checks
- ✅ Access control with tx-sender
- ✅ Post-conditions for safety
- ✅ Visible source code on-chain

---

## 🌐 Interact with Deployed Contracts

### Using Stacks CLI

```bash
# Read counter value
stx call_read_only_contract_func \
  <CONTRACT_ADDRESS> counter get-counter \
  --network testnet

# Increment counter
stx call_contract_func \
  <CONTRACT_ADDRESS> counter increment \
  --network testnet \
  --private-key <YOUR_PRIVATE_KEY>

# Transfer tokens
stx call_contract_func \
  <CONTRACT_ADDRESS> token transfer \
  u100 <SENDER> <RECIPIENT> none \
  --network testnet \
  --private-key <YOUR_PRIVATE_KEY>
```

### Using Clarinet Console

```clarity
;; Increment counter
(contract-call? .counter increment)

;; Get counter
(contract-call? .counter get-counter)

;; Transfer tokens
(contract-call? .token transfer u100 tx-sender 'ST1PQHQKV0RJXZFY1DGX8MNSNYVE3VGZJSRTPGZGM none)
```

---

## 🔧 Development Tools

### Clarinet
- Local development environment
- Testing framework
- Deployment management
- REPL console

### Stacks Explorer
- View deployed contracts
- https://explorer.stacks.co/

### Hiro Wallet
- Browser wallet for Stacks
- https://wallet.hiro.so/

---

## 📊 Best Practices

### Error Handling
```clarity
(define-constant err-unauthorized (err u100))
(define-constant err-insufficient-balance (err u101))

(asserts! (is-eq tx-sender contract-owner) err-unauthorized)
```

### Event Logging
```clarity
(print {
  event: "transfer",
  from: sender,
  to: recipient,
  amount: amount
})
```

### Access Control
```clarity
(define-constant contract-owner tx-sender)
(asserts! (is-eq tx-sender contract-owner) err-owner-only)
```

---

## 🌐 Networks

### Testnet
- Network: `testnet`
- Explorer: https://explorer.stacks.co/?chain=testnet
- Faucet: https://explorer.stacks.co/sandbox/faucet?chain=testnet

### Mainnet
- Network: `mainnet`
- Explorer: https://explorer.stacks.co/

---

## 📖 Resources

- [Clarity Language Book](https://book.clarity-lang.org/)
- [Stacks Documentation](https://docs.stacks.co/)
- [Clarinet Documentation](https://docs.hiro.so/clarinet/)
- [SIP-010 Standard](https://github.com/stacksgov/sips/blob/main/sips/sip-010/sip-010-fungible-token-standard.md)
- [Clarity Examples](https://github.com/hirosystems/clarity-examples)
- [Stacks Academy](https://academy.stacks.org/)

---

## 🧪 Example Test Structure

```typescript
import { Clarinet, Tx, Chain, Account, types } from 'clarinet';
import { assertEquals } from 'https://deno.land/std/testing/asserts.ts';

Clarinet.test({
  name: "Test counter operations",
  async fn(chain: Chain, accounts: Map<string, Account>) {
    const deployer = accounts.get('deployer')!;

    // Increment
    let block = chain.mineBlock([
      Tx.contractCall('counter', 'increment', [], deployer.address),
    ]);
    assertEquals(block.receipts[0].result, '(ok u1)');

    // Get counter
    let result = chain.callReadOnlyFn(
      'counter',
      'get-counter',
      [],
      deployer.address
    );
    assertEquals(result.result, '(ok u1)');
  },
});
```

---

## 🤝 Contributing

Contributions are welcome! Please ensure:
- Clarity code passes `clarinet check`
- All tests pass
- Follow Clarity best practices
- Include comprehensive tests

---

## 📝 License

MIT License - See LICENSE file for details

---

## 🔗 Related

- [Cairo Contracts](../../cairo/starknet-contract/)
- [Ink! Contracts](../../ink/polkadot-contract/)
- [Solidity Contracts](../../solidity/)

---

**Building on Bitcoin with Stacks ❤️**
