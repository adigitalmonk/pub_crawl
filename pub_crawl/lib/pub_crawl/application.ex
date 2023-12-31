defmodule PubCrawl.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      {Phoenix.PubSub, name: PubCrawl.PubSub},
      PubCrawl.KV,
      {Tango, port: 4040, handler: PubCrawl.Tango.Handler}
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: PubCrawl.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
