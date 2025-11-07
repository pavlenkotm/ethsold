# 🦀 Rust - Solana Programs

This directory contains Solana programs written in Rust using the Anchor framework.

## 📋 Overview

Solana is a high-performance blockchain supporting smart contracts called "programs". Anchor is the most popular framework for Solana development, providing:
- Type-safe program development
- Automatic serialization/deserialization
- Built-in security checks
- IDL generation for clients

## 🎯 Counter Program

A simple counter program demonstrating:
- Account initialization
- State management
- Authority-based access control
- Arithmetic operations with overflow protection
- Event logging with `msg!` macro

### Features

- **Initialize**: Create a new counter starting at 0
- **Increment**: Increase counter by 1
- **Decrement**: Decrease counter by 1
- **Set**: Set counter to specific value (authority only)
- **Reset**: Reset counter to 0 (authority only)

## 🚀 Quick Start

### Prerequisites

- Rust >= 1.70.0
- Solana CLI >= 1.16.0
- Anchor CLI >= 0.29.0
- Node.js >= 16 (for testing)

### Installation

```bash
# Install Rust
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh

# Install Solana CLI
sh -c "$(curl -sSfL https://release.solana.com/stable/install)"

# Install Anchor
cargo install --git https://github.com/coral-xyz/anchor avm --locked --force
avm install latest
avm use latest
```

### Build the Program

```bash
cd rust/solana-program
anchor build
```

### Run Tests

```bash
anchor test
```

### Deploy to Devnet

```bash
# Configure CLI for devnet
solana config set --url devnet

# Airdrop SOL for deployment
solana airdrop 2

# Deploy
anchor deploy
```

## 📁 Project Structure

```
solana-program/
├── Cargo.toml              # Rust dependencies
├── src/
│   └── lib.rs             # Main program logic
├── Anchor.toml            # Anchor configuration
└── tests/                 # TypeScript tests
```

## 🔑 Key Concepts

### Accounts
Solana programs are stateless. All state is stored in accounts:
```rust
#[account]
pub struct Counter {
    pub count: u64,
    pub authority: Pubkey,
}
```

### Instructions
Functions that modify account state:
```rust
pub fn increment(ctx: Context<Update>) -> Result<()> {
    let counter = &mut ctx.accounts.counter;
    counter.count = counter.count.checked_add(1)?;
    Ok(())
}
```

### Context
Defines required accounts for each instruction:
```rust
#[derive(Accounts)]
pub struct Update<'info> {
    #[account(mut)]
    pub counter: Account<'info, Counter>,
    pub user: Signer<'info>,
}
```

## 🧪 Testing

Anchor provides a TypeScript testing framework:

```typescript
import * as anchor from "@coral-xyz/anchor";
import { Program } from "@coral-xyz/anchor";
import { CounterProgram } from "../target/types/counter_program";

describe("counter-program", () => {
  const provider = anchor.AnchorProvider.env();
  anchor.setProvider(provider);

  const program = anchor.workspace.CounterProgram as Program<CounterProgram>;

  it("Initializes counter", async () => {
    const counter = anchor.web3.Keypair.generate();

    await program.methods
      .initialize()
      .accounts({
        counter: counter.publicKey,
        user: provider.wallet.publicKey,
        systemProgram: anchor.web3.SystemProgram.programId,
      })
      .signers([counter])
      .rpc();
  });

  it("Increments counter", async () => {
    await program.methods
      .increment()
      .accounts({
        counter: counter.publicKey,
        user: provider.wallet.publicKey,
      })
      .rpc();
  });
});
```

## 🔒 Security Features

- **Overflow Protection**: Uses `checked_add` and `checked_sub`
- **Access Control**: Authority checks for privileged operations
- **Account Validation**: Anchor's automatic account validation
- **Type Safety**: Rust's type system prevents many bugs

## 📚 Resources

- [Solana Documentation](https://docs.solana.com/)
- [Anchor Book](https://book.anchor-lang.com/)
- [Anchor Examples](https://github.com/coral-xyz/anchor/tree/master/tests)
- [Solana Cookbook](https://solanacookbook.com/)
- [Solana Program Library](https://spl.solana.com/)

## 💡 Next Steps

- Explore SPL Token program
- Implement Program Derived Addresses (PDAs)
- Add Cross-Program Invocations (CPI)
- Build a decentralized exchange (DEX)
- Create NFT minting program

## 📝 License

MIT License
