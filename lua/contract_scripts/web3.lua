-- Ethereum smart contract interaction script in Lua
-- Lightweight scripting for blockchain automation

local json = require("dkjson")  -- or use cjson
local http = require("socket.http")
local ltn12 = require("ltn12")

-- Web3 Client
local Web3 = {}
Web3.__index = Web3

function Web3:new(rpc_url)
    local obj = {
        url = rpc_url or "http://localhost:8545",
        request_id = 1
    }
    setmetatable(obj, self)
    return obj
end

-- RPC call helper
function Web3:rpc_call(method, params)
    params = params or {}

    local request = {
        jsonrpc = "2.0",
        method = method,
        params = params,
        id = self.request_id
    }

    self.request_id = self.request_id + 1

    local request_body = json.encode(request)
    local response_body = {}

    local res, code, headers, status = http.request({
        url = self.url,
        method = "POST",
        headers = {
            ["Content-Type"] = "application/json",
            ["Content-Length"] = tostring(#request_body)
        },
        source = ltn12.source.string(request_body),
        sink = ltn12.sink.table(response_body)
    })

    if code ~= 200 then
        error("HTTP request failed: " .. tostring(code))
    end

    local response = json.decode(table.concat(response_body))

    if response.error then
        error("RPC error: " .. response.error.message)
    end

    return response.result
end

-- Get block number
function Web3:block_number()
    local result = self:rpc_call("eth_blockNumber")
    return tonumber(result, 16)
end

-- Get balance
function Web3:get_balance(address, block)
    block = block or "latest"
    local result = self:rpc_call("eth_getBalance", {address, block})
    return tonumber(result, 16)
end

-- Get balance in ETH
function Web3:get_balance_eth(address)
    local wei = self:get_balance(address)
    return wei / 1e18
end

-- Get transaction count (nonce)
function Web3:get_transaction_count(address, block)
    block = block or "latest"
    local result = self:rpc_call("eth_getTransactionCount", {address, block})
    return tonumber(result, 16)
end

-- Get gas price
function Web3:gas_price()
    local result = self:rpc_call("eth_gasPrice")
    return tonumber(result, 16)
end

-- Get transaction
function Web3:get_transaction(tx_hash)
    return self:rpc_call("eth_getTransactionByHash", {tx_hash})
end

-- Get transaction receipt
function Web3:get_transaction_receipt(tx_hash)
    return self:rpc_call("eth_getTransactionReceipt", {tx_hash})
end

-- Call smart contract (read-only)
function Web3:call(to, data, block)
    block = block or "latest"
    local params = {
        {to = to, data = data},
        block
    }
    return self:rpc_call("eth_call", params)
end

-- Estimate gas
function Web3:estimate_gas(from, to, value, data)
    local params = {{
        from = from,
        to = to,
        value = value or "0x0",
        data = data or "0x"
    }}
    local result = self:rpc_call("eth_estimateGas", params)
    return tonumber(result, 16)
end

-- Send raw transaction
function Web3:send_raw_transaction(signed_tx)
    return self:rpc_call("eth_sendRawTransaction", {signed_tx})
end

-- Contract ABI encoder/decoder helper
local ABI = {}

function ABI.encode_uint256(value)
    return string.format("%064x", value)
end

function ABI.encode_address(address)
    local clean = address:gsub("^0x", "")
    return string.format("%064s", clean)
end

function ABI.encode_function(signature, params)
    -- Compute function selector (first 4 bytes of keccak256)
    -- This is simplified - in production use proper keccak256
    local selector = signature:sub(1, 10)  -- Placeholder
    return selector .. table.concat(params, "")
end

function ABI.decode_uint256(data)
    return tonumber(data, 16)
end

-- Example smart contract wrapper
local ERC20 = {}
ERC20.__index = ERC20

function ERC20:new(web3, contract_address)
    local obj = {
        web3 = web3,
        address = contract_address
    }
    setmetatable(obj, self)
    return obj
end

function ERC20:balance_of(owner_address)
    local data = "0x70a08231" .. ABI.encode_address(owner_address)
    local result = self.web3:call(self.address, data)
    return ABI.decode_uint256(result:gsub("^0x", ""))
end

function ERC20:total_supply()
    local data = "0x18160ddd"  -- totalSupply()
    local result = self.web3:call(self.address, data)
    return ABI.decode_uint256(result:gsub("^0x", ""))
end

function ERC20:decimals()
    local data = "0x313ce567"  -- decimals()
    local result = self.web3:call(self.address, data)
    return ABI.decode_uint256(result:gsub("^0x", ""))
end

-- Export modules
return {
    Web3 = Web3,
    ABI = ABI,
    ERC20 = ERC20
}

-- Example usage (when run as script)
if arg and arg[0]:match("web3%.lua$") then
    print("=== Lua Ethereum Web3 Script ===")
    print("")

    -- Create client
    local client = Web3:new("https://eth-mainnet.g.alchemy.com/v2/demo")

    -- Get block number
    local block_num = client:block_number()
    print(string.format("Current Block: %d", block_num))

    -- Get balance
    local address = "0x742d35Cc6634C0532925a3b844Bc9e7595f0bEb"
    local balance = client:get_balance_eth(address)
    print(string.format("Balance: %.4f ETH", balance))

    -- Get gas price
    local gas_price = client:gas_price()
    print(string.format("Gas Price: %d Wei", gas_price))

    print("")
    print("✓ All operations completed successfully!")
end
