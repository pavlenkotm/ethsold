# Crystal Blockchain Tools

Fast, compiled Ethereum blockchain tools written in Crystal.

## Features

- **Fast** - Compiled to native code like C
- **Ruby-like Syntax** - Clean, elegant code
- **Type Safe** - Static typing with type inference
- **Concurrent** - Lightweight fibers for concurrency
- **Low Memory** - Efficient memory usage

## Installation

```bash
# Install Crystal
curl -fsSL https://crystal-lang.org/install.sh | sudo bash

# Build
crystal build src/web3_client.cr

# Run
./web3_client
```

## Usage

```crystal
require "./src/web3_client"

client = Web3::Client.new("https://eth-mainnet.g.alchemy.com/v2/YOUR_KEY")

# Get block number
block_num = client.block_number

# Get balance
balance = client.get_balance_eth("0x...")

# Call contract
result = client.call("0xContractAddress", "0xFunctionData")
```

## Why Crystal?

- Ruby-like syntax with C performance
- Compiled, not interpreted
- Perfect for blockchain tools
- Strong standard library

## License

MIT
