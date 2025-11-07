# 🐍 Python Web3 CLI Tools

Command-line tools and utilities for Ethereum blockchain interactions using Web3.py.

## 📋 Overview

This directory contains Python scripts demonstrating:
- **wallet_manager.py** - Wallet creation, balance checking, transactions, signing
- **contract_deployer.py** - Smart contract compilation and deployment
- **block_explorer.py** - Query blockchain data

## ✨ Features

- 🔑 **Wallet Management** - Create wallets, check balances, send ETH
- 📝 **Message Signing** - Sign and verify messages
- 📜 **Contract Deployment** - Compile and deploy Solidity contracts
- 🔍 **Blockchain Queries** - Read blocks, transactions, events
- 🎨 **Beautiful CLI** - Rich terminal output with colors

## 🚀 Quick Start

### Prerequisites

- Python >= 3.10
- pip

### Installation

```bash
cd python/web3-cli
pip install -r requirements.txt
```

### Configuration

Set your RPC URL (optional, defaults to localhost):

```bash
export WEB3_RPC_URL="https://eth-sepolia.g.alchemy.com/v2/YOUR-API-KEY"
```

Or use `.env` file:
```bash
WEB3_RPC_URL=https://eth-sepolia.g.alchemy.com/v2/YOUR-API-KEY
PRIVATE_KEY=your_private_key_here
```

## 🎯 Usage

### Wallet Manager

**Create a new wallet:**
```bash
python wallet_manager.py create
```

**Check balance:**
```bash
python wallet_manager.py balance 0x742d35Cc6634C0532925a3b844Bc9e7595f0bEb
```

**Send ETH:**
```bash
python wallet_manager.py send <private_key> <to_address> <amount>
```

**Sign a message:**
```bash
python wallet_manager.py sign <private_key> "Hello Web3"
```

### Contract Deployer

```python
from contract_deployer import ContractDeployer

# Initialize
deployer = ContractDeployer(
    rpc_url="http://localhost:8545",
    private_key="0x..."
)

# Compile contract
abi, bytecode = deployer.compile_contract(
    source_code=SIMPLE_TOKEN,
    contract_name="SimpleToken"
)

# Deploy
contract_address = deployer.deploy_contract(
    abi, bytecode,
    "MyToken", "MTK", 1000000  # constructor args
)

# Interact
balance = deployer.call_function(
    contract_address, abi,
    "balanceOf", deployer.address
)

# Send transaction
tx_hash = deployer.send_transaction(
    contract_address, abi,
    "transfer", "0x...", 100
)
```

## 📁 Project Structure

```
web3-cli/
├── wallet_manager.py       # Wallet operations CLI
├── contract_deployer.py    # Contract deployment
├── block_explorer.py       # Blockchain queries
├── requirements.txt        # Python dependencies
└── README.md
```

## 🔑 Key Features

### 1. Web3 Connection

```python
from web3 import Web3

w3 = Web3(Web3.HTTPProvider('http://localhost:8545'))

# Check connection
if w3.is_connected():
    print(f"Connected to chain {w3.eth.chain_id}")
    print(f"Latest block: {w3.eth.block_number}")
```

### 2. Account Management

```python
from eth_account import Account

# Create account
account = Account.create()
print(f"Address: {account.address}")
print(f"Private Key: {account.key.hex()}")

# Load from private key
account = Account.from_key("0x...")
```

### 3. Send Transaction

```python
# Build transaction
tx = {
    'nonce': w3.eth.get_transaction_count(from_address),
    'to': to_address,
    'value': w3.to_wei(1, 'ether'),
    'gas': 21000,
    'gasPrice': w3.eth.gas_price,
    'chainId': w3.eth.chain_id
}

# Sign
signed = w3.eth.account.sign_transaction(tx, private_key)

# Send
tx_hash = w3.eth.send_raw_transaction(signed.rawTransaction)

# Wait for receipt
receipt = w3.eth.wait_for_transaction_receipt(tx_hash)
```

### 4. Contract Interaction

```python
# Read function
contract = w3.eth.contract(address=contract_address, abi=abi)
result = contract.functions.balanceOf(address).call()

# Write function
tx = contract.functions.transfer(to, amount).build_transaction({
    'from': from_address,
    'nonce': w3.eth.get_transaction_count(from_address),
    'gas': 100000,
    'gasPrice': w3.eth.gas_price
})

signed = w3.eth.account.sign_transaction(tx, private_key)
tx_hash = w3.eth.send_raw_transaction(signed.rawTransaction)
```

### 5. Event Filtering

```python
# Get past events
events = contract.events.Transfer.get_logs(
    fromBlock=0,
    toBlock='latest'
)

for event in events:
    print(f"Transfer: {event['args']['from']} -> {event['args']['to']}")
```

## 🧪 Testing

```bash
# Run with local Hardhat node
npx hardhat node

# In another terminal
python wallet_manager.py balance 0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266
```

## 🔒 Security Best Practices

- ✅ Never hardcode private keys
- ✅ Use environment variables or secure vaults
- ✅ Validate all addresses with checksums
- ✅ Test on testnets before mainnet
- ✅ Implement proper error handling
- ✅ Use gas estimation for transactions

## 📦 Key Dependencies

| Package | Purpose |
|---------|---------|
| web3.py | Ethereum library |
| eth-account | Account management |
| py-solc-x | Solidity compiler |
| python-dotenv | Environment variables |
| click | CLI framework |
| rich | Terminal formatting |

## 💡 Advanced Examples

### ENS Resolution
```python
# Resolve ENS name
address = w3.ens.address('vitalik.eth')

# Reverse resolution
name = w3.ens.name('0x...')
```

### Gas Estimation
```python
gas_estimate = w3.eth.estimate_gas({
    'to': to_address,
    'from': from_address,
    'value': w3.to_wei(1, 'ether')
})
```

### Event Subscription (WebSocket)
```python
from web3 import Web3

w3 = Web3(Web3.WebsocketProvider('wss://...'))

# Subscribe to new blocks
def handle_block(block):
    print(f"New block: {block['number']}")

block_filter = w3.eth.filter('latest')
w3.eth.filter_poll(block_filter, handle_block)
```

## 📚 Resources

- [Web3.py Documentation](https://web3py.readthedocs.io/)
- [Ethereum Python](https://ethereum.org/en/developers/docs/programming-languages/python/)
- [eth-account](https://eth-account.readthedocs.io/)
- [py-solc-x](https://github.com/iamdefinitelyahuman/py-solc-x)

## 🚀 Next Steps

- Add support for EIP-1559 transactions
- Implement multi-signature wallets
- Create DeFi interaction scripts (Uniswap, Aave)
- Build NFT minting/transfer tools
- Add comprehensive testing suite

## 📝 License

MIT License
