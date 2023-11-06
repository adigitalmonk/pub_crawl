defmodule PubCrawl.Tango do
  use Tango,
    port: 4040,
    handler: PubCrawl.Tango.Handler
end
