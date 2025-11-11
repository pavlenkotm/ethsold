defmodule BlockchainNode do
  @moduledoc """
  Ethereum blockchain node interface written in Elixir.

  Provides a functional, fault-tolerant interface to Ethereum nodes
  with built-in supervision and error handling.
  """

  @doc """
  Get the current block number.

  ## Examples

      iex> BlockchainNode.block_number()
      {:ok, 18_500_000}
  """
  def block_number do
    with {:ok, hex_number} <- Ethereumex.HttpClient.eth_block_number() do
      {:ok, hex_to_integer(hex_number)}
    end
  end

  @doc """
  Get block by number or hash.

  ## Examples

      iex> BlockchainNode.get_block(18_500_000)
      {:ok, %{...}}
  """
  def get_block(block_identifier, full_transactions \\ false) do
    identifier =
      case block_identifier do
        num when is_integer(num) -> integer_to_hex(num)
        "latest" -> "latest"
        "pending" -> "pending"
        "earliest" -> "earliest"
        hash when is_binary(hash) -> hash
      end

    Ethereumex.HttpClient.eth_get_block_by_number(identifier, full_transactions)
  end

  @doc """
  Get transaction by hash.
  """
  def get_transaction(tx_hash) do
    Ethereumex.HttpClient.eth_get_transaction_by_hash(tx_hash)
  end

  @doc """
  Get account balance.

  ## Examples

      iex> BlockchainNode.get_balance("0x742d35Cc6634C0532925a3b844Bc9e7595f0bEb")
      {:ok, 1_000_000_000_000_000_000}  # 1 ETH in wei
  """
  def get_balance(address, block \\ "latest") do
    with {:ok, hex_balance} <- Ethereumex.HttpClient.eth_get_balance(address, block) do
      {:ok, hex_to_integer(hex_balance)}
    end
  end

  @doc """
  Get transaction count (nonce) for an address.
  """
  def get_transaction_count(address, block \\ "latest") do
    with {:ok, hex_count} <- Ethereumex.HttpClient.eth_get_transaction_count(address, block) do
      {:ok, hex_to_integer(hex_count)}
    end
  end

  @doc """
  Call a smart contract function.
  """
  def call_contract(to, data, block \\ "latest") do
    params = %{
      to: to,
      data: data
    }

    Ethereumex.HttpClient.eth_call(params, block)
  end

  @doc """
  Estimate gas for a transaction.
  """
  def estimate_gas(params) do
    with {:ok, hex_gas} <- Ethereumex.HttpClient.eth_estimate_gas(params) do
      {:ok, hex_to_integer(hex_gas)}
    end
  end

  @doc """
  Get current gas price.
  """
  def gas_price do
    with {:ok, hex_price} <- Ethereumex.HttpClient.eth_gas_price() do
      {:ok, hex_to_integer(hex_price)}
    end
  end

  @doc """
  Send raw transaction.
  """
  def send_raw_transaction(signed_tx) do
    Ethereumex.HttpClient.eth_send_raw_transaction(signed_tx)
  end

  @doc """
  Get transaction receipt.
  """
  def get_transaction_receipt(tx_hash) do
    Ethereumex.HttpClient.eth_get_transaction_receipt(tx_hash)
  end

  @doc """
  Subscribe to new blocks (requires WebSocket connection).
  """
  def subscribe_new_blocks(callback) do
    BlockchainNode.Subscriber.subscribe(:new_heads, callback)
  end

  @doc """
  Subscribe to pending transactions.
  """
  def subscribe_pending_transactions(callback) do
    BlockchainNode.Subscriber.subscribe(:pending_transactions, callback)
  end

  # Helper functions

  defp hex_to_integer("0x" <> hex) do
    String.to_integer(hex, 16)
  end

  defp hex_to_integer(hex) when is_binary(hex) do
    String.to_integer(hex, 16)
  end

  defp integer_to_hex(num) when is_integer(num) do
    "0x" <> Integer.to_string(num, 16)
  end
end
