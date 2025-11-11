require "http/client"
require "json"
require "big"

module Web3
  # Ethereum JSON-RPC client written in Crystal
  class Client
    getter url : String

    def initialize(@url : String = "http://localhost:8545")
    end

    # Get current block number
    def block_number : BigInt
      response = rpc_call("eth_blockNumber", [] of String)
      hex_to_int(response.as_s)
    end

    # Get account balance
    def get_balance(address : String, block : String = "latest") : BigInt
      response = rpc_call("eth_getBalance", [address, block])
      hex_to_int(response.as_s)
    end

    # Get balance in ETH
    def get_balance_eth(address : String) : BigDecimal
      wei = get_balance(address)
      BigDecimal.new(wei) / BigDecimal.new(10) ** 18
    end

    # Get transaction count (nonce)
    def get_transaction_count(address : String, block : String = "latest") : BigInt
      response = rpc_call("eth_getTransactionCount", [address, block])
      hex_to_int(response.as_s)
    end

    # Get current gas price
    def gas_price : BigInt
      response = rpc_call("eth_gasPrice", [] of String)
      hex_to_int(response.as_s)
    end

    # Get transaction by hash
    def get_transaction(tx_hash : String) : JSON::Any
      rpc_call("eth_getTransactionByHash", [tx_hash])
    end

    # Get transaction receipt
    def get_transaction_receipt(tx_hash : String) : JSON::Any
      rpc_call("eth_getTransactionReceipt", [tx_hash])
    end

    # Get block by number
    def get_block(block_number : Int | String, full_tx : Bool = false) : JSON::Any
      block_param = case block_number
      when Int
        int_to_hex(BigInt.new(block_number))
      else
        block_number.to_s
      end

      rpc_call("eth_getBlockByNumber", [block_param, full_tx])
    end

    # Call smart contract (read-only)
    def call(to : String, data : String, block : String = "latest") : String
      params = {
        "to" => to,
        "data" => data
      }
      response = rpc_call("eth_call", [params, block])
      response.as_s
    end

    # Estimate gas
    def estimate_gas(from : String, to : String, value : BigInt = BigInt.new(0), data : String = "0x") : BigInt
      params = {
        "from" => from,
        "to" => to,
        "value" => int_to_hex(value),
        "data" => data
      }
      response = rpc_call("eth_estimateGas", [params])
      hex_to_int(response.as_s)
    end

    # Send raw transaction
    def send_raw_transaction(signed_tx : String) : String
      response = rpc_call("eth_sendRawTransaction", [signed_tx])
      response.as_s
    end

    # Get network ID
    def network_id : Int64
      response = rpc_call("net_version", [] of String)
      response.as_s.to_i64
    end

    # Check if node is syncing
    def syncing : Bool | JSON::Any
      response = rpc_call("eth_syncing", [] of String)
      case response.raw
      when Bool
        response.as_bool
      else
        response
      end
    end

    private def rpc_call(method : String, params : Array) : JSON::Any
      request_id = Random.rand(1..9999)

      payload = {
        "jsonrpc" => "2.0",
        "method" => method,
        "params" => params,
        "id" => request_id
      }.to_json

      response = HTTP::Client.post(
        @url,
        headers: HTTP::Headers{"Content-Type" => "application/json"},
        body: payload
      )

      json = JSON.parse(response.body)

      if json["error"]?
        raise "RPC Error: #{json["error"]}"
      end

      json["result"]
    end

    private def hex_to_int(hex : String) : BigInt
      hex = hex.lchop("0x")
      BigInt.new(hex, 16)
    end

    private def int_to_hex(num : BigInt) : String
      "0x#{num.to_s(16)}"
    end
  end

  # Transaction builder
  class Transaction
    property nonce : BigInt
    property gas_price : BigInt
    property gas_limit : BigInt
    property to : String
    property value : BigInt
    property data : String

    def initialize(@nonce, @gas_price, @gas_limit, @to, @value, @data = "0x")
    end

    def to_json : String
      {
        "nonce" => "0x#{@nonce.to_s(16)}",
        "gasPrice" => "0x#{@gas_price.to_s(16)}",
        "gas" => "0x#{@gas_limit.to_s(16)}",
        "to" => @to,
        "value" => "0x#{@value.to_s(16)}",
        "data" => @data
      }.to_json
    end
  end
end

# Example usage
if ARGV.size == 0
  puts "=== Crystal Ethereum Web3 Client ==="
  puts ""

  client = Web3::Client.new("https://eth-mainnet.g.alchemy.com/v2/demo")

  # Get block number
  block_num = client.block_number
  puts "Current Block: #{block_num}"

  # Get balance
  address = "0x742d35Cc6634C0532925a3b844Bc9e7595f0bEb"
  balance = client.get_balance_eth(address)
  puts "Balance: #{balance} ETH"

  # Get gas price
  gas_price = client.gas_price
  puts "Gas Price: #{gas_price} Wei"

  # Get network ID
  network = client.network_id
  puts "Network ID: #{network}"

  puts ""
  puts "✓ All operations completed successfully!"
end
