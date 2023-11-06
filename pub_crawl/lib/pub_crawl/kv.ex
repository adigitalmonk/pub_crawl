defmodule PubCrawl.KV do
  use GenServer
  alias PubCrawl.PubSub

  def start_link(opts) do
    name = opts[:name] || __MODULE__
    GenServer.start_link(__MODULE__, :ok, name: name)
  end

  def init(_ok) do
    {:ok, %{}}
  end

  def follow(key) do
    PubSub.subscribe_to(key)
  end

  def unfollow(key) do
    PubSub.unsubscribe_from(key)
  end

  def get(key, name \\ __MODULE__) when is_binary(key) do
    GenServer.call(name, {:get, key})
  end

  def put(key, value, name \\ __MODULE__) when is_binary(key) do
    GenServer.cast(name, {:put, key, value})
  end

  def handle_cast({:put, key, new_value}, state) when is_binary(key) do
    {old_value, new_state} = Map.get_and_update(state, key, fn current ->
      {current, new_value}
    end)

    PubSub.value_updated(key, old_value, new_value)
    {:noreply, new_state}
  end

  def handle_call({:get, key}, _from, state) when is_binary(key) do
    {:reply, state[key], state}
  end

end
