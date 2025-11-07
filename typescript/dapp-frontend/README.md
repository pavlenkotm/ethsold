# ⚛️ TypeScript DApp Frontend

A modern, production-ready Web3 DApp frontend built with TypeScript, React, Wagmi v2, and Viem.

## 📋 Overview

This project demonstrates best practices for building Web3 applications with:
- **TypeScript** - Type-safe development
- **React 18** - Modern UI framework
- **Wagmi v2** - React hooks for Ethereum
- **Viem** - Lightweight alternative to ethers.js
- **RainbowKit** (optional) - Beautiful wallet connection UI

## ✨ Features

- 🔌 **Multi-wallet Support** - MetaMask, WalletConnect, Coinbase Wallet
- 🌐 **Multi-chain** - Ethereum, Polygon, Arbitrum, Optimism
- 💰 **Token Interactions** - Read balances, transfer ERC-20 tokens
- 📡 **Real-time Updates** - Automatic balance updates
- 🎨 **Responsive Design** - Works on desktop and mobile
- ⚡ **Fast & Lightweight** - Viem is 10x smaller than ethers.js

## 🚀 Quick Start

### Prerequisites

- Node.js >= 18
- npm or yarn
- MetaMask or another Web3 wallet

### Installation

```bash
cd typescript/dapp-frontend
npm install
```

### Configuration

Create a `.env` file:

```bash
# Optional: WalletConnect Project ID
VITE_WALLETCONNECT_PROJECT_ID=your_project_id_here

# Optional: Custom RPC URLs
VITE_MAINNET_RPC_URL=https://eth-mainnet.g.alchemy.com/v2/YOUR-API-KEY
VITE_SEPOLIA_RPC_URL=https://eth-sepolia.g.alchemy.com/v2/YOUR-API-KEY
```

Get a WalletConnect Project ID: https://cloud.walletconnect.com/

### Development

```bash
npm run dev
```

Open http://localhost:5173

### Build for Production

```bash
npm run build
npm run preview
```

## 📁 Project Structure

```
dapp-frontend/
├── src/
│   ├── components/          # React components
│   │   ├── WalletConnect.tsx
│   │   └── TokenBalance.tsx
│   ├── App.tsx             # Main application
│   ├── wagmi.config.ts     # Wagmi configuration
│   ├── App.css             # Styles
│   └── main.tsx            # Entry point
├── package.json
├── tsconfig.json
├── vite.config.ts
└── README.md
```

## 🔑 Key Technologies

### Wagmi v2
Modern React hooks for Ethereum:

```typescript
import { useAccount, useBalance, useReadContract } from 'wagmi'

function Component() {
  const { address, isConnected } = useAccount()
  const { data: balance } = useBalance({ address })

  // ... your component logic
}
```

### Viem
Type-safe Ethereum interactions:

```typescript
import { parseEther, formatEther } from 'viem'

const amount = parseEther('1.0') // 1000000000000000000n
const formatted = formatEther(1000000000000000000n) // "1.0"
```

### Contract Interactions

Reading data:
```typescript
const { data } = useReadContract({
  address: '0x...',
  abi: ERC20_ABI,
  functionName: 'balanceOf',
  args: [userAddress],
})
```

Writing data:
```typescript
const { writeContract } = useWriteContract()

writeContract({
  address: '0x...',
  abi: ERC20_ABI,
  functionName: 'transfer',
  args: [recipient, amount],
})
```

## 🎯 Features Walkthrough

### 1. Wallet Connection
- Click "Connect Wallet" button
- Choose your preferred wallet (MetaMask, WalletConnect, etc.)
- Approve connection in your wallet
- View connected address and balance

### 2. Token Information
- Enter any ERC-20 token contract address
- View token name, symbol, and your balance
- Supports all standard ERC-20 tokens

### 3. Token Transfer
- Enter recipient address
- Enter amount to transfer
- Click "Transfer" button
- Confirm transaction in wallet
- View transaction status and hash

## 🔒 Security Best Practices

- ✅ All user inputs are validated
- ✅ Contract addresses are checksummed
- ✅ Transaction signing happens in user's wallet
- ✅ Private keys never leave the wallet
- ✅ Type-safe with TypeScript
- ✅ No sensitive data in frontend code

## 🧪 Testing

```bash
# Type checking
npm run typecheck

# Linting
npm run lint
```

## 📦 Key Dependencies

| Package | Version | Purpose |
|---------|---------|---------|
| react | ^18.2.0 | UI framework |
| wagmi | ^2.5.0 | Ethereum React hooks |
| viem | ^2.7.0 | Ethereum library |
| @tanstack/react-query | ^5.28.0 | Data fetching |
| @rainbow-me/rainbowkit | ^2.0.0 | Wallet UI (optional) |

## 🌐 Supported Networks

- Ethereum Mainnet
- Sepolia Testnet
- Polygon
- Arbitrum
- Optimism

Add more chains in `wagmi.config.ts`:

```typescript
import { base, zora } from 'wagmi/chains'

export const config = createConfig({
  chains: [mainnet, sepolia, polygon, base, zora],
  // ...
})
```

## 💡 Advanced Features

### Add Transaction History
```typescript
import { useTransaction, useBlockNumber } from 'wagmi'
```

### Implement ENS Resolution
```typescript
import { useEnsName, useEnsAvatar } from 'wagmi'

const { data: ensName } = useEnsName({ address })
```

### Add Token Approval
```typescript
const { writeContract } = useWriteContract()

writeContract({
  address: tokenAddress,
  abi: ERC20_ABI,
  functionName: 'approve',
  args: [spenderAddress, amount],
})
```

## 📚 Resources

- [Wagmi Documentation](https://wagmi.sh/)
- [Viem Documentation](https://viem.sh/)
- [React Documentation](https://react.dev/)
- [TypeScript Handbook](https://www.typescriptlang.org/docs/)
- [RainbowKit](https://www.rainbowkit.com/)

## 🚀 Deployment

### Vercel
```bash
npm install -g vercel
vercel
```

### Netlify
```bash
npm run build
# Upload dist/ folder to Netlify
```

### GitHub Pages
```bash
npm run build
# Push dist/ to gh-pages branch
```

## 📝 License

MIT License
