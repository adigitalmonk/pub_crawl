defmodule PubCrawl.MixProject do
  use Mix.Project

  def project do
    [
      app: :pub_crawl,
      version: "0.1.0",
      elixir: "~> 1.15",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger],
      mod: {PubCrawl.Application, []}
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  def deps do
    [
        {:echo, github: "adigitalmonk/echo", branch: "main"},
        {:phoenix_pubsub, "~> 2.0"}
    ]
  end
end
