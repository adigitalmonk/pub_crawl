defmodule PubCrawl.Tango.Handler do
  use Echo.Handler
  alias PubCrawl.KV

  def handle_in(message) do
    message
    |> String.trim()
    |> String.split(" ", parts: 3)
  end

  def handle_message(["#pub", key, data], socket) do
    KV.put(key, data)
    {:reply, "ok", socket}
  end

  def handle_message(["#peek", key], socket) do
    response =
      case KV.get(key) do
        nil -> "<- err # unknown value"
        val -> val
      end

    {:reply, response, socket}
  end

  def handle_message(["#sub", key], socket) do
    KV.follow(key)
    {:reply, "ok", socket}
  end

  def handle_message(["#unsub", key], socket) do
    KV.unfollow(key)
    {:reply, "ok", socket}
  end

  def handle_message(_message, socket) do
    {:reply, "unknown_cmd", socket}
  end

  def handle_info({:update, key, old, new}, socket) do
    old = if is_nil(old), do: "[empty]", else: old
    new = if is_nil(new), do: "[empty]", else: new
    {:reply, "->updated #{key} : #{old} -> #{new}", socket}
  end

  def handle_info(_event, socket) do
    # fall through
    {:noreply, socket}
  end
end
