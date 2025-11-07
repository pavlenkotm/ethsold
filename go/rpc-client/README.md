# 🔷 Go Ethereum RPC Client

A production-ready Go library and CLI for interacting with Ethereum nodes using go-ethereum (geth).

## 📋 Overview

This Go module demonstrates:
- RPC client for Ethereum interactions
- Wallet operations (balance, send)
- Message signing and verification
- Transaction handling
- Type-safe blockchain queries

## ✨ Features

- 🔌 **RPC Connection** - Connect to any Ethereum node
- 💰 **Balance Queries** - Check ETH balances
- 📤 **Send Transactions** - Transfer ETH securely
- ✍️ **Message Signing** - Sign and verify messages
- 🔍 **Block Queries** - Get latest block information
- 🛡️ **Type Safety** - Leverages Go's type system

## 🚀 Quick Start

### Prerequisites

- Go >= 1.21
- Ethereum node RPC endpoint

### Installation

```bash
cd go/rpc-client
go mod download
```

### Build

```bash
go build -o web3-cli main.go
```

### Usage

**Get balance:**
```bash
go run main.go balance 0x742d35Cc6634C0532925a3b844Bc9e7595f0bEb
```

**Get latest block:**
```bash
go run main.go block
```

**Sign message:**
```bash
go run main.go sign <private_key> "Hello Web3"
```

**Send ETH:**
```bash
go run main.go send <private_key> <to_address> <amount_in_wei>
```

### Environment Variables

```bash
export ETH_RPC_URL="https://eth-sepolia.g.alchemy.com/v2/YOUR-KEY"
```

## 📁 Project Structure

```
rpc-client/
├── main.go       # Main implementation
├── go.mod        # Go module definition
├── go.sum        # Dependency checksums
└── README.md
```

## 🔑 Key Components

### Web3Client

```go
client, err := NewWeb3Client("http://localhost:8545")
if err != nil {
    log.Fatal(err)
}

// Get balance
balance, err := client.GetBalance("0x...")
fmt.Printf("Balance: %s wei\n", balance.String())

// Get block number
blockNum, err := client.GetBlockNumber()
fmt.Printf("Block: %d\n", blockNum)
```

### Transaction Sending

```go
amount := big.NewInt(1000000000000000000) // 1 ETH

txHash, err := client.SendTransaction(
    privateKey,
    toAddress,
    amount,
)
```

### Message Signing

```go
signature, err := SignMessage(privateKey, "Hello")

// Verify
valid, err := VerifySignature(
    "Hello",
    signature,
    expectedAddress,
)
```

## 📦 Dependencies

- **go-ethereum** - Official Go implementation of Ethereum
- **crypto** - Cryptographic operations
- **big** - Arbitrary precision arithmetic

## 🧪 Testing

```bash
# Run tests
go test ./...

# Run with coverage
go test -cover ./...

# Benchmark
go test -bench=. ./...
```

## 🔒 Security

- ✅ Private keys handled securely
- ✅ EIP-155 replay protection
- ✅ Proper nonce management
- ✅ Gas estimation included
- ✅ Type-safe interfaces

## 💡 Use as Library

```go
package main

import (
    "github.com/web3-playground/go-rpc-client"
    "github.com/ethereum/go-ethereum/common"
)

func main() {
    client, _ := NewWeb3Client("http://localhost:8545")

    balance, _ := client.GetBalance("0x...")
    // Use balance...
}
```

## 📚 Resources

- [go-ethereum Documentation](https://geth.ethereum.org/docs)
- [Go Ethereum Book](https://goethereumbook.org/)
- [Ethereum JSON-RPC](https://ethereum.org/en/developers/docs/apis/json-rpc/)
- [Go by Example](https://gobyexample.com/)

## 🚀 Next Steps

- Add smart contract interactions
- Implement EIP-1559 transactions
- Add event filtering
- Create multi-signature wallet
- Build DeFi integration examples

## 📝 License

MIT License
