defmodule BlockchainNode.Subscriber do
  @moduledoc """
  GenServer for managing blockchain event subscriptions.
  Supports subscriptions to new blocks, pending transactions, and logs.
  """

  use GenServer
  require Logger

  # Client API

  def start_link(_opts) do
    GenServer.start_link(__MODULE__, %{subscribers: %{}}, name: __MODULE__)
  end

  def subscribe(event_type, callback) when is_function(callback, 1) do
    GenServer.call(__MODULE__, {:subscribe, event_type, callback})
  end

  def unsubscribe(subscription_id) do
    GenServer.call(__MODULE__, {:unsubscribe, subscription_id})
  end

  def notify(event_type, data) do
    GenServer.cast(__MODULE__, {:notify, event_type, data})
  end

  # Server Callbacks

  @impl true
  def init(state) do
    {:ok, state}
  end

  @impl true
  def handle_call({:subscribe, event_type, callback}, _from, state) do
    subscription_id = generate_subscription_id()

    subscribers =
      state.subscribers
      |> Map.put_new(event_type, %{})
      |> Map.update!(event_type, &Map.put(&1, subscription_id, callback))

    Logger.info("New subscription: #{event_type} (#{subscription_id})")

    {:reply, {:ok, subscription_id}, %{state | subscribers: subscribers}}
  end

  @impl true
  def handle_call({:unsubscribe, subscription_id}, _from, state) do
    subscribers =
      state.subscribers
      |> Enum.map(fn {event_type, subs} ->
        {event_type, Map.delete(subs, subscription_id)}
      end)
      |> Map.new()

    Logger.info("Unsubscribed: #{subscription_id}")

    {:reply, :ok, %{state | subscribers: subscribers}}
  end

  @impl true
  def handle_cast({:notify, event_type, data}, state) do
    case Map.get(state.subscribers, event_type) do
      nil ->
        {:noreply, state}

      subscribers ->
        Enum.each(subscribers, fn {_id, callback} ->
          Task.Supervisor.start_child(BlockchainNode.TaskSupervisor, fn ->
            try do
              callback.(data)
            rescue
              e ->
                Logger.error("Subscription callback error: #{inspect(e)}")
            end
          end)
        end)

        {:noreply, state}
    end
  end

  # Private Functions

  defp generate_subscription_id do
    :crypto.strong_rand_bytes(16) |> Base.encode16(case: :lower)
  end
end
