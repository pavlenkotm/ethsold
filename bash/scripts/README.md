# 🐚 Bash Scripts for Ethereum Operations

Production-ready Bash scripts for automating common Ethereum development and deployment tasks.

## 📋 Overview

This collection includes:
- **deploy-node.sh** - Automated node deployment (Geth, Hardhat)
- **smart-contract-deploy.sh** - Contract compilation and deployment
- **monitor-network.sh** - Network monitoring and metrics

## ✨ Features

- 🐳 **Docker Support** - Containerized node deployment
- ⚙️ **Configurable** - Environment-based configuration
- 🎨 **Colored Output** - Easy-to-read terminal output
- 🔄 **Automation** - One-command deployments
- 📊 **Monitoring** - Real-time network stats

## 🚀 Quick Start

### Prerequisites

- Bash >= 4.0
- Docker and Docker Compose
- Node.js (for Hardhat/Foundry)
- curl, jq

### Make Scripts Executable

```bash
chmod +x bash/scripts/*.sh
```

## 📜 Script Documentation

### deploy-node.sh

Deploy and manage Ethereum nodes.

**Usage:**
```bash
# Deploy Geth node on Sepolia
./deploy-node.sh deploy-geth

# Deploy to mainnet
NETWORK=mainnet ./deploy-node.sh deploy-geth

# Deploy Hardhat local node
./deploy-node.sh deploy-hardhat

# Check node status
./deploy-node.sh status

# View logs
./deploy-node.sh logs

# Stop node
./deploy-node.sh stop

# Cleanup data
./deploy-node.sh cleanup
```

**Environment Variables:**
- `NODE_TYPE` - Type of node (geth, hardhat)
- `NETWORK` - Network (mainnet, sepolia, goerli)
- `DATA_DIR` - Data directory path
- `HTTP_PORT` - HTTP RPC port (default: 8545)
- `WS_PORT` - WebSocket port (default: 8546)

**Examples:**
```bash
# Custom configuration
export NETWORK=mainnet
export DATA_DIR=/mnt/ethereum
export HTTP_PORT=8555
./deploy-node.sh deploy-geth

# Quick local development
./deploy-node.sh deploy-hardhat
```

### smart-contract-deploy.sh

Compile, test, and deploy smart contracts.

**Usage:**
```bash
# Compile contracts
./smart-contract-deploy.sh compile

# Run tests
./smart-contract-deploy.sh test

# Deploy contract
./smart-contract-deploy.sh deploy SimpleToken

# Verify on Etherscan
./smart-contract-deploy.sh verify 0x123... "arg1" "arg2"

# Do everything
./smart-contract-deploy.sh all MyContract
```

**Environment Variables:**
- `CONTRACT_DIR` - Contracts directory
- `BUILD_DIR` - Build output directory
- `NETWORK` - Target network
- `RPC_URL` - RPC endpoint
- `PRIVATE_KEY` - Deployment private key
- `ETHERSCAN_API_KEY` - For verification

**Examples:**
```bash
# Deploy to Sepolia
export NETWORK=sepolia
export RPC_URL="https://eth-sepolia.g.alchemy.com/v2/YOUR-KEY"
export PRIVATE_KEY="0x..."
./smart-contract-deploy.sh deploy MyContract

# Full deployment pipeline
export NETWORK=mainnet
./smart-contract-deploy.sh compile
./smart-contract-deploy.sh test
./smart-contract-deploy.sh deploy MyContract
```

## 🔧 Advanced Usage

### Custom Node Configuration

Create a configuration file `node.conf`:

```bash
# node.conf
NODE_TYPE=geth
NETWORK=mainnet
DATA_DIR=/mnt/ethereum/data
HTTP_PORT=8545
WS_PORT=8546
SYNC_MODE=snap
CACHE_SIZE=8192
```

Load and use:
```bash
source node.conf
./deploy-node.sh deploy-geth
```

### Docker Compose Integration

The scripts generate docker-compose.yml files automatically:

```yaml
version: '3.8'
services:
  geth:
    image: ethereum/client-go:latest
    ports:
      - "8545:8545"
      - "8546:8546"
    volumes:
      - ./ethereum-data:/root/.ethereum
    command:
      - --sepolia
      - --http
      - --http.addr=0.0.0.0
```

### CI/CD Integration

**GitHub Actions Example:**

```yaml
name: Deploy Contracts

on:
  push:
    branches: [main]

jobs:
  deploy:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3

      - name: Deploy Contracts
        env:
          NETWORK: sepolia
          PRIVATE_KEY: ${{ secrets.PRIVATE_KEY }}
          RPC_URL: ${{ secrets.RPC_URL }}
        run: |
          chmod +x bash/scripts/smart-contract-deploy.sh
          ./bash/scripts/smart-contract-deploy.sh all
```

## 🔒 Security Best Practices

- ✅ Never commit private keys
- ✅ Use environment variables or secret managers
- ✅ Validate all inputs
- ✅ Set proper file permissions (600 for configs)
- ✅ Use secure RPC endpoints
- ✅ Implement rate limiting

**Secure Key Management:**

```bash
# Store in encrypted file
echo "PRIVATE_KEY=0x..." | gpg --encrypt > .env.gpg

# Decrypt and load
gpg --decrypt .env.gpg | source /dev/stdin
./smart-contract-deploy.sh deploy
```

## 📊 Monitoring

### Check Node Health

```bash
# RPC health check
curl -X POST -H "Content-Type: application/json" \
  --data '{"jsonrpc":"2.0","method":"eth_blockNumber","params":[],"id":1}' \
  http://localhost:8545

# Get sync status
curl -X POST -H "Content-Type: application/json" \
  --data '{"jsonrpc":"2.0","method":"eth_syncing","params":[],"id":1}' \
  http://localhost:8545
```

### Continuous Monitoring

```bash
#!/bin/bash
while true; do
    ./deploy-node.sh status
    sleep 60
done
```

## 🧪 Testing Scripts

```bash
# Test with shellcheck
shellcheck bash/scripts/*.sh

# Run in dry-run mode (if supported)
DRY_RUN=true ./deploy-node.sh deploy-geth
```

## 📚 Resources

- [Bash Best Practices](https://google.github.io/styleguide/shellguide.html)
- [Geth Documentation](https://geth.ethereum.org/docs)
- [Docker Documentation](https://docs.docker.com/)
- [Hardhat Documentation](https://hardhat.org/)

## 💡 Tips & Tricks

### Parallel Execution

```bash
# Deploy multiple contracts in parallel
contracts=("Token" "NFT" "DAO")
for contract in "${contracts[@]}"; do
    ./smart-contract-deploy.sh deploy "$contract" &
done
wait
```

### Logging

```bash
# Log all output
./deploy-node.sh deploy-geth 2>&1 | tee deployment.log

# Log with timestamps
./deploy-node.sh deploy-geth 2>&1 | ts '[%Y-%m-%d %H:%M:%S]' | tee log.txt
```

## 📝 License

MIT License
