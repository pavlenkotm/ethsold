defmodule BlockchainNode.BlockCache do
  @moduledoc """
  GenServer for caching blockchain data with TTL.
  Provides fast access to frequently requested blocks and transactions.
  """

  use GenServer
  require Logger

  @cache_ttl :timer.minutes(5)

  # Client API

  def start_link(_opts) do
    GenServer.start_link(__MODULE__, %{}, name: __MODULE__)
  end

  def get(key) do
    GenServer.call(__MODULE__, {:get, key})
  end

  def put(key, value, ttl \\ @cache_ttl) do
    GenServer.cast(__MODULE__, {:put, key, value, ttl})
  end

  def delete(key) do
    GenServer.cast(__MODULE__, {:delete, key})
  end

  def clear do
    GenServer.cast(__MODULE__, :clear)
  end

  # Server Callbacks

  @impl true
  def init(_) do
    schedule_cleanup()
    {:ok, %{}}
  end

  @impl true
  def handle_call({:get, key}, _from, state) do
    case Map.get(state, key) do
      {value, expires_at} ->
        if System.monotonic_time(:millisecond) < expires_at do
          {:reply, {:ok, value}, state}
        else
          {:reply, :error, Map.delete(state, key)}
        end

      nil ->
        {:reply, :error, state}
    end
  end

  @impl true
  def handle_cast({:put, key, value, ttl}, state) do
    expires_at = System.monotonic_time(:millisecond) + ttl
    {:noreply, Map.put(state, key, {value, expires_at})}
  end

  @impl true
  def handle_cast({:delete, key}, state) do
    {:noreply, Map.delete(state, key)}
  end

  @impl true
  def handle_cast(:clear, _state) do
    {:noreply, %{}}
  end

  @impl true
  def handle_info(:cleanup, state) do
    now = System.monotonic_time(:millisecond)

    new_state =
      state
      |> Enum.reject(fn {_key, {_value, expires_at}} -> expires_at < now end)
      |> Map.new()

    schedule_cleanup()
    {:noreply, new_state}
  end

  # Private Functions

  defp schedule_cleanup do
    Process.send_after(self(), :cleanup, :timer.minutes(1))
  end
end
