# Nim Ethereum Keccak256

High-performance Keccak256 hash implementation in Nim for Ethereum operations.

## Features

- **Fast** - Compiled to native code, C-like performance
- **Memory Efficient** - Minimal runtime overhead
- **Type Safe** - Static typing with type inference
- **Python-like Syntax** - Clean, readable code
- **Zero-Cost Abstractions** - High-level code, low-level performance

## Installation

```bash
# Install Nim
curl https://nim-lang.org/choosenim/init.sh -sSf | sh

# Install dependencies
nimble install nimcrypto

# Build
nimble build

# Run
./keccak
```

## Usage

```nim
import keccak

# Hash a string
let hash = keccak256("Hello, Ethereum!")
echo hash.toHex()

# Generate Ethereum address
let address = addressFromPublicKey(publicKey)

# EIP-55 checksum
let checksummed = checksumAddress("0x...")
let isValid = verifyChecksum(checksummed)
```

## Why Nim?

- Compiles to C for maximum performance
- Python-like syntax with static typing
- Excellent for blockchain/crypto operations
- Memory safe with minimal overhead

## License

MIT
