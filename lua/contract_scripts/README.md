# Lua Smart Contract Scripts

Lightweight Ethereum smart contract interaction scripts written in Lua.

## Features

- **Lightweight** - Minimal dependencies
- **Scriptable** - Perfect for automation
- **Embeddable** - Easy to embed in applications
- **Fast** - JIT compilation with LuaJIT
- **Simple** - Easy to learn and use

## Installation

```bash
# Install Lua and LuaRocks
sudo apt-get install lua5.4 luarocks

# Install dependencies
luarocks install dkjson
luarocks install luasocket
```

## Usage

```lua
local web3 = require("web3")

-- Create client
local client = web3.Web3:new("https://eth-mainnet.g.alchemy.com/v2/YOUR_KEY")

-- Get block number
local block_num = client:block_number()
print("Block:", block_num)

-- Get balance
local balance = client:get_balance_eth("0x...")
print("Balance:", balance, "ETH")

-- Interact with ERC20 token
local token = web3.ERC20:new(client, "0xTokenAddress")
local token_balance = token:balance_of("0xOwnerAddress")
print("Token Balance:", token_balance)
```

## Running Scripts

```bash
# Run example
lua web3.lua

# Use in your scripts
lua your_script.lua
```

## Why Lua?

- Perfect for scripting blockchain automation
- Embeddable in applications
- Fast with LuaJIT
- Simple, clean syntax
- Low resource usage

## License

MIT
