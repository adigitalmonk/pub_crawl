defmodule PubClient do
  @moduledoc """
  # References
  https://andrealeopardi.com/posts/handling-tcp-connections-in-elixir/
  https://www.erlang.org/doc/man/gen_tcp.html
  """
  use GenServer
  require Logger

  def start_link(opts \\ []) do
    name = Keyword.get(opts, :name, __MODULE__)
    GenServer.start_link(__MODULE__, opts, name: name)
  end

  def peek(key, name \\ __MODULE__) do
    GenServer.call(name, {:peek, key})
  end

  def pub(key, value, name \\ __MODULE__) do
    GenServer.call(name, {:pub, key, value})
  end

  def sub(key, name \\ __MODULE__) do
    GenServer.call(name, {:sub, key})
  end

  def unsub(key, name \\ __MODULE__) do
    GenServer.call(name, {:unsub, key})
  end

  @impl GenServer
  def init(_opts) do
    {:ok, port} = :gen_tcp.connect(~c"localhost", 4040, [:binary, active: true])
    {:ok, %{port: port, queue: :queue.new()}}
  end

  @impl GenServer
  def handle_info({:tcp, _socket, msg}, state) do
    state =
      msg
      |> String.trim()
      |> String.split("\n")
      |> Enum.reduce(state, fn message, state ->
        message
        |> String.trim()
        |> rx(state)
      end)

    {:noreply, state}
  end

  def handle_info(info, port) do
    Logger.debug("Unhandled handle_info: #{inspect(info)}")
    {:noreply, port}
  end

  @impl GenServer
  def handle_call({:peek, key}, from, %{port: port, queue: queue} = state) do
    :ok = tx(port, "#peek #{key}")
    {:noreply, %{state | queue: :queue.in(from, queue)}}
  end

  def handle_call({:sub, key}, from, %{port: port, queue: queue} = state) do
    :ok = tx(port, "#sub #{key}")
    {:noreply, %{state | queue: :queue.in(from, queue)}}
  end

  def handle_call({:unsub, key}, from, %{port: port, queue: queue} = state) do
    :ok = tx(port, "#unsub #{key}")
    {:noreply, %{state | queue: :queue.in(from, queue)}}
  end

  @impl GenServer
  def handle_call({:pub, key, value}, from, %{port: port, queue: queue} = state) do
    :ok = tx(port, "#pub #{key} #{value}")
    {:noreply, %{state | queue: :queue.in(from, queue)}}
  end

  def prepare_rx(message) do
    String.trim(message)
  end

  def prepare_tx(message) do
    "#{message}\n"
  end

  def tx(port, cmd) do
    message = prepare_tx(cmd)

    case :gen_tcp.send(port, message) do
      :ok -> :ok
      _ -> {:error, :send_fail}
    end
  end


  def rx(<<"->", _::binary>> = event, state) do
    Logger.info("RECEIVED EVENT: #{prepare_rx(event)}")
    state
  end

  def rx(message, %{queue: queue} = state) do
    message = prepare_rx(message)

    case :queue.out(queue) do
      {{:value, from}, new_queue} ->
        GenServer.reply(from, message)
        %{state | queue: new_queue}

      _ ->
        Logger.debug("NOISE: #{inspect(message)}")
        state
    end
  end
end
