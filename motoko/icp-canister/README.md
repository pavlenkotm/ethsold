# 🌐 Motoko Smart Contracts for DFINITY Internet Computer

Production-ready Motoko canisters for the Internet Computer Protocol (ICP).

## 📋 Overview

Motoko is a programming language designed specifically for the Internet Computer, offering seamless integration with ICP's unique features like orthogonal persistence, actor-based concurrency, and automatic state management.

### Canisters Included

1. **Counter Canister** - Persistent counter with event logging and access control
2. **Token Canister** - DIP20-like fungible token with full transaction history

---

## 🚀 Prerequisites

### Install DFX (DFINITY SDK)

```bash
# Install DFX
sh -ci "$(curl -fsSL https://internetcomputer.org/install.sh)"

# Verify installation
dfx --version
```

### Install Node.js (for frontend integration)

```bash
# Install Node.js (if not installed)
# Visit https://nodejs.org/ or use nvm
nvm install 18
nvm use 18
```

---

## 📦 Project Structure

```
motoko/icp-canister/
├── counter.mo            # Counter canister
├── token.mo             # Token canister
├── dfx.json             # DFX configuration
└── README.md            # This file
```

---

## 🛠️ Setup

### Initialize DFX Project

```bash
cd motoko/icp-canister

# Start local replica
dfx start --background

# Create identity (if needed)
dfx identity new developer
dfx identity use developer
```

---

## 🔨 Build & Deploy

### Build Canisters

```bash
# Build all canisters
dfx build

# Build specific canister
dfx build counter
dfx build token
```

### Deploy Locally

```bash
# Deploy all canisters
dfx deploy

# Deploy specific canister
dfx deploy counter
dfx deploy token

# Get canister IDs
dfx canister id counter
dfx canister id token
```

---

## 🧪 Testing & Interaction

### Counter Canister

```bash
# Initialize (set owner)
dfx canister call counter init

# Get counter value
dfx canister call counter get

# Increment counter
dfx canister call counter increment

# Decrement counter
dfx canister call counter decrement

# Increment by amount
dfx canister call counter incrementBy '(5)'

# Get owner
dfx canister call counter getOwner

# Get total increments
dfx canister call counter getTotalIncrements

# Reset (owner only)
dfx canister call counter reset

# Set counter (owner only)
dfx canister call counter setCounter '(42)'

# Get recent events
dfx canister call counter getRecentEvents
```

### Token Canister

```bash
# Initialize token
dfx canister call token init '("My Token", "MTK", 8, 1000000)'

# Get metadata
dfx canister call token getMetadata

# Get balance
dfx canister call token balanceOf "(principal \"$(dfx identity get-principal)\")"

# Transfer tokens
dfx canister call token transfer "(principal \"aaaaa-aa\", 100)"

# Approve spender
dfx canister call token approve "(principal \"aaaaa-aa\", 100)"

# Get allowance
dfx canister call token allowance "(principal \"$(dfx identity get-principal)\", principal \"aaaaa-aa\")"

# Mint tokens (owner only)
dfx canister call token mint "(principal \"$(dfx identity get-principal)\", 1000)"

# Burn tokens
dfx canister call token burn "(100)"

# Get transaction history
dfx canister call token getTransactionHistory
```

---

## 🚀 Deploy to Mainnet

### 1. Add Cycles

```bash
# Get cycles from cycles faucet or exchange
# https://internetcomputer.org/docs/current/developer-docs/setup/cycles/

# Create cycles wallet
dfx wallet --network ic create

# Check wallet balance
dfx wallet --network ic balance
```

### 2. Deploy to IC Mainnet

```bash
# Deploy to mainnet
dfx deploy --network ic

# Deploy specific canister
dfx deploy --network ic counter
dfx deploy --network ic token

# Get mainnet canister ID
dfx canister --network ic id counter
dfx canister --network ic id token
```

### 3. Interact with Mainnet

```bash
# Call mainnet canister
dfx canister --network ic call counter increment

# Call with query (faster, no consensus)
dfx canister --network ic call counter get
```

---

## 📚 Canister Details

### Counter Canister

**Features:**
- Persistent state across upgrades
- Owner-based access control
- Event logging system
- Per-user increment tracking
- Safe arithmetic operations
- Query and update methods

**Public Methods:**
```motoko
// Queries (fast, no state change)
get() : async Int
getOwner() : async Principal
getTotalIncrements() : async Nat
getUserIncrements(Principal) : async Nat
getRecentEvents() : async [Event]
getAllEvents() : async [Event]

// Updates (state changing)
init() : async ()
increment() : async Int
decrement() : async ?Int
incrementBy(Nat) : async Int
reset() : async ?Int
setCounter(Int) : async ?Int
clearEvents() : async Bool
```

### Token Canister

**Features:**
- DIP20-like interface
- Transaction history
- Mint/burn capabilities
- Allowance system
- Upgrade-safe storage
- Comprehensive metadata

**Public Methods:**
```motoko
// Queries
name() : async Text
symbol() : async Text
decimals() : async Nat8
totalSupply() : async Nat
owner() : async Principal
balanceOf(Principal) : async Nat
allowance(Principal, Principal) : async Nat
getMetadata() : async Metadata
getTransactionHistory() : async [TxRecord]

// Updates
init(Text, Text, Nat8, Nat) : async ()
transfer(Principal, Nat) : async Result<Nat, Text>
transferFrom(Principal, Principal, Nat) : async Result<Nat, Text>
approve(Principal, Nat) : async Result<Nat, Text>
mint(Principal, Nat) : async Result<Nat, Text>
burn(Nat) : async Result<Nat, Text>
```

---

## 🔒 Security Features

- ✅ Orthogonal persistence (automatic state management)
- ✅ Actor-based isolation
- ✅ Caller authentication via `msg.caller`
- ✅ Upgrade safety with stable variables
- ✅ Type safety with Motoko's type system
- ✅ Overflow protection

---

## 🔧 Development Commands

### DFX Commands

```bash
# Start local replica
dfx start --clean

# Stop replica
dfx stop

# Deploy canisters
dfx deploy

# Upgrade canister
dfx canister install <canister-name> --mode upgrade

# Check canister status
dfx canister status <canister-name>

# Get canister info
dfx canister info <canister-name>

# Delete canister
dfx canister delete <canister-name>

# Generate candid interface
dfx build <canister-name>
cat .dfx/local/canisters/<canister-name>/<canister-name>.did
```

### Identity Management

```bash
# Create new identity
dfx identity new <name>

# Use identity
dfx identity use <name>

# List identities
dfx identity list

# Get principal
dfx identity get-principal

# Get wallet address
dfx identity get-wallet
```

---

## 🌐 Upgrade Management

Motoko canisters support seamless upgrades with stable variables:

```motoko
// Declare stable variables
private stable var counter : Int = 0;
private stable var entries : [(Principal, Nat)] = [];

// Preupgrade hook
system func preupgrade() {
    // Save runtime state to stable variables
    entries := Iter.toArray(map.entries());
};

// Postupgrade hook
system func postupgrade() {
    // Restore runtime state from stable variables
    map := HashMap.fromIter(entries.vals(), ...);
    entries := [];
};
```

---

## 📊 Monitoring & Debugging

### Check Canister Logs

```bash
# View logs
dfx canister logs <canister-name>

# Continuous logs
dfx canister logs <canister-name> --follow
```

### Canister Metrics

```bash
# Check cycles balance
dfx canister status <canister-name>

# Memory usage
dfx canister status <canister-name> | grep memory_size
```

---

## 🌐 Frontend Integration

```javascript
import { Actor, HttpAgent } from '@dfinity/agent';
import { idlFactory } from './declarations/counter';

// Create agent
const agent = new HttpAgent({ host: 'http://localhost:8000' });

// Create actor
const counter = Actor.createActor(idlFactory, {
  agent,
  canisterId: 'rrkah-fqaaa-aaaaa-aaaaq-cai',
});

// Call methods
const value = await counter.get();
await counter.increment();
```

---

## 📖 Resources

- [Motoko Language Guide](https://internetcomputer.org/docs/current/motoko/main/motoko)
- [Internet Computer Docs](https://internetcomputer.org/docs/current/home)
- [DFX SDK Documentation](https://internetcomputer.org/docs/current/developer-docs/setup/install)
- [Motoko Base Library](https://internetcomputer.org/docs/current/motoko/main/base/)
- [Awesome Internet Computer](https://github.com/dfinity/awesome-internet-computer)
- [IC Developer Portal](https://internetcomputer.org/docs/current/developer-docs/ic-overview)

---

## 🧪 Testing Best Practices

### Unit Testing

```bash
# Run Motoko tests
moc -r <test-file>.mo
```

### Integration Testing

```bash
# Deploy to local replica
dfx start --clean
dfx deploy

# Run test suite
npm test
```

---

## 🎯 Common Patterns

### Error Handling

```motoko
public func divide(a: Nat, b: Nat) : async ?Nat {
    if (b == 0) {
        return null;
    };
    ?(a / b)
};
```

### Access Control

```motoko
public shared(msg) func restrictedFunction() : async Bool {
    if (not Principal.equal(msg.caller, owner)) {
        return false;
    };
    // Protected logic
    true
};
```

---

## 🤝 Contributing

Contributions are welcome! Please ensure:
- Code compiles with latest Motoko version
- All tests pass
- Follow Motoko style guide
- Add documentation for new features

---

## 📝 License

MIT License - See LICENSE file for details

---

## 🔗 Related

- [Cairo Contracts](../../cairo/starknet-contract/)
- [Ink! Contracts](../../ink/polkadot-contract/)
- [Clarity Contracts](../../clarity/stacks-contract/)

---

**Building on the Internet Computer ∞**
