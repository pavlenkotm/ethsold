# Frequently Asked Questions (FAQ)

## General Questions

### What is this repository?

This is a comprehensive Web3 development showcase featuring examples in 15+ programming languages across multiple blockchain platforms (Ethereum, Solana, Aptos, Cardano, etc.).

### Who is this for?

- Developers learning blockchain development
- Those showcasing multi-language expertise
- Educators teaching Web3 development
- Anyone comparing blockchain platforms

### Can I use this code in production?

The code is production-quality but should be audited before mainnet deployment. Use at your own risk.

## Solidity Questions

### Which Solidity version should I use?

We use Solidity ^0.8.20 for all contracts. This version includes built-in overflow protection.

### How do I deploy contracts?

```bash
cd solidity
npm install
npx hardhat run scripts/deploy.js --network sepolia
```

### How do I verify contracts on Etherscan?

```bash
npx hardhat verify --network sepolia CONTRACT_ADDRESS "Constructor" "Args"
```

## TypeScript DApp Questions

### Which wallet libraries are used?

We use Wagmi v2 (React hooks) and Viem (lightweight Web3 library) for the best developer experience.

### How do I connect to different networks?

Edit `wagmi.config.ts` to add/remove chains.

### Can I use this with React Native?

The current example is web-only, but Wagmi supports React Native with some modifications.

## Python Questions

### Which Python version is required?

Python 3.10+ is required for all Python examples.

### Can I use this with Django/Flask?

Yes! The Web3.py examples can be integrated into any Python framework.

## Rust/Solana Questions

### Do I need Solana CLI installed?

Yes, for deployment. For development, Anchor handles most operations.

### How do I deploy to Solana devnet?

```bash
cd rust/solana-program
anchor build
anchor deploy --provider.cluster devnet
```

## Testing Questions

### How do I run all tests?

Each project has its own tests:
```bash
# Solidity
cd solidity && npx hardhat test

# Python
cd python/web3-cli && pytest

# TypeScript
cd typescript/dapp-frontend && npm test
```

### Are tests required for contributions?

Yes, PRs should include tests for new features.

## Deployment Questions

### What are the gas costs?

Varies by network and contract complexity. Test on testnet first and use gas estimators.

### Can I deploy to mainnet?

Yes, but exercise extreme caution:
1. Audit your code
2. Test thoroughly on testnet
3. Use hardware wallet
4. Start with small amounts

## Security Questions

### Are these contracts audited?

No formal audit has been conducted. Audit before production use.

### How do I report security issues?

See [SECURITY.md](../SECURITY.md) for responsible disclosure procedures.

### Should I use these contracts as-is?

Review and modify for your specific needs. Add additional security measures as required.

## Contributing Questions

### How can I contribute?

See [CONTRIBUTING.md](../CONTRIBUTING.md) for guidelines.

### What kind of contributions are welcome?

- New language examples
- Bug fixes
- Documentation improvements
- Test additions
- Performance optimizations

### Do I need to know all languages?

No! Contribute in the languages you know.

## Technical Questions

### Why use Wagmi instead of web3.js?

Wagmi provides React hooks, automatic caching, and is more lightweight than traditional libraries.

### Why Anchor for Solana?

Anchor is the most popular Solana framework, providing better developer experience and security features.

### Can I add more blockchain platforms?

Yes! PRs adding new platforms (Avalanche, Polkadot, etc.) are welcome.

## Troubleshooting

### "Module not found" errors

Ensure you've installed dependencies:
```bash
npm install  # or pip install -r requirements.txt
```

### Contract deployment fails

Check:
- Sufficient balance for gas
- Correct network configuration
- Valid private key
- RPC endpoint is working

### Tests failing

- Update dependencies
- Check Node.js/Python version
- Ensure local node is running (if needed)

## Still Have Questions?

- Check project documentation
- Search existing [GitHub Issues](https://github.com/pavlenkotm/ethsold/issues)
- Open a new issue
- Start a [Discussion](https://github.com/pavlenkotm/ethsold/discussions)
