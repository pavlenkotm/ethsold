# Deployment Guide

This guide covers deployment procedures for various components.

## Solidity Smart Contracts

### Local Deployment (Hardhat)

```bash
cd solidity

# Start local node
npx hardhat node

# Deploy contracts (new terminal)
npx hardhat run scripts/deploy.js --network localhost
```

### Testnet Deployment (Sepolia)

```bash
# Configure environment
cp .env.example .env
# Edit .env with your PRIVATE_KEY and RPC_URL

# Deploy
npx hardhat run scripts/deploy.js --network sepolia

# Verify on Etherscan
npx hardhat verify --network sepolia CONTRACT_ADDRESS "Constructor" "Arguments"
```

### Mainnet Deployment

⚠️ **Exercise extreme caution**

```bash
# Triple-check everything
# Use hardware wallet or secure key management
# Test on testnet first

npx hardhat run scripts/deploy.js --network mainnet
```

## TypeScript DApp

### Development

```bash
cd typescript/dapp-frontend
npm install
npm run dev
```

### Production Build

```bash
npm run build
npm run preview  # Test production build locally
```

### Deploy to Vercel

```bash
# Install Vercel CLI
npm i -g vercel

# Deploy
vercel

# Production deployment
vercel --prod
```

### Deploy to Netlify

```bash
# Build
npm run build

# Deploy dist/ folder to Netlify via UI
# Or use Netlify CLI
netlify deploy --prod
```

## Python CLI Tools

### Installation

```bash
cd python/web3-cli
pip install -r requirements.txt
```

### Distribution

```bash
# Build package
python setup.py sdist bdist_wheel

# Upload to PyPI
twine upload dist/*
```

## Bash Scripts

### Setup

```bash
cd bash/scripts
chmod +x *.sh
```

### Deploy Ethereum Node

```bash
# Geth on Sepolia
./deploy-node.sh deploy-geth

# Local Hardhat node
./deploy-node.sh deploy-hardhat
```

## Docker Deployment

### Build Images

```bash
# Node
docker build -t ethereum-node -f docker/Dockerfile.geth .

# DApp
docker build -t web3-dapp -f docker/Dockerfile.frontend .
```

### Docker Compose

```bash
docker-compose up -d
```

## Security Checklist

Before deployment:

- [ ] All tests passing
- [ ] Security audit completed
- [ ] Environment variables secured
- [ ] Private keys in secure storage
- [ ] Gas limits configured
- [ ] Rate limiting enabled
- [ ] Monitoring set up
- [ ] Backup procedures tested

## Monitoring

### Smart Contracts

- Use Etherscan/block explorers
- Set up alerts for events
- Monitor gas usage

### Frontend

- Use Vercel Analytics
- Set up error tracking (Sentry)
- Monitor API calls

### Backend

- Use logging (Winston, Bunyan)
- Set up health checks
- Monitor resource usage

## Rollback Procedures

### Smart Contracts

⚠️ Immutable - cannot rollback
- Use upgradeable patterns if needed
- Have emergency pause mechanism

### Frontend

```bash
# Vercel
vercel rollback

# Netlify
# Use UI to rollback to previous deployment
```

## Cost Estimation

### Deployment Costs (Approximate)

| Network | Average Gas | Cost (ETH) |
|---------|-------------|------------|
| Mainnet | 2M gas | ~0.02-0.1 |
| Sepolia | 2M gas | 0 (test ETH) |

### Hosting Costs

| Service | Cost |
|---------|------|
| Vercel (Hobby) | Free |
| Netlify (Starter) | Free |
| AWS EC2 (t2.micro) | ~$8/month |

## Support

For deployment issues:
- Check documentation
- Review GitHub issues
- Contact maintainers
