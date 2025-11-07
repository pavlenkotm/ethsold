# 🎩 Haskell Plutus Smart Contracts

Cardano smart contracts written in Plutus (Haskell-based language).

## 📋 Overview

Plutus is Cardano's smart contract platform, using Haskell for:
- Type-safe contract development
- Formal verification
- Functional programming paradigm
- UTXO-based model

## ✨ Features

- 🎯 **Type Safety** - Compile-time guarantees
- 🔍 **Formal Verification** - Provable correctness
- 💎 **Functional** - Pure functions, immutability
- 🧮 **UTXO Model** - Different from Ethereum's account model

## 🚀 Quick Start

### Prerequisites

- GHC >= 8.10
- Cabal >= 3.4
- Nix (recommended)

### Installation

```bash
# Install using Nix
nix-shell

# Or manually with Cabal
cabal update
cabal install plutus-ledger plutus-tx plutus-contract
```

### Compile

```bash
cabal build
```

## 📝 Contract Examples

### Vesting Contract

Locks funds until a deadline:

```haskell
data VestingDatum = VestingDatum
    { beneficiary :: PaymentPubKeyHash
    , deadline    :: POSIXTime
    }

mkValidator :: VestingDatum -> VestingRedeemer -> ScriptContext -> Bool
mkValidator dat Claim ctx =
    signedByBeneficiary && deadlineReached
```

### Token Minting

Simple token minting policy:

```haskell
mkPolicy :: PaymentPubKeyHash -> () -> ScriptContext -> Bool
mkPolicy pkh () ctx =
    txSignedBy (scriptContextTxInfo ctx) $ unPaymentPubKeyHash pkh
```

## 🔑 Key Concepts

### UTXO vs Account Model

**Ethereum (Account):**
- Global state
- Mutable balances
- Gas-based execution

**Cardano (UTXO):**
- Local state (per UTXO)
- Immutable outputs
- Deterministic validation

### Plutus Components

1. **On-Chain** - Validators (Haskell)
2. **Off-Chain** - Transaction construction (Haskell)
3. **PAB** - Plutus Application Backend

## 📚 Resources

- [Plutus Documentation](https://plutus.readthedocs.io/)
- [Cardano Docs](https://docs.cardano.org/)
- [Plutus Pioneer Program](https://github.com/input-output-hk/plutus-pioneer-program)

## 📝 License

MIT License
