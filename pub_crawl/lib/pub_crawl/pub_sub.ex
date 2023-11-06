defmodule PubCrawl.PubSub do
  alias Phoenix.PubSub

  def subscribe_to(subject) do
    PubSub.subscribe(__MODULE__, subject)
  end

  def unsubscribe_from(subject) do
    PubSub.unsubscribe(__MODULE__, subject)
  end

  def value_updated(subject, old_value, new_value) do
    PubSub.broadcast(__MODULE__, subject, {:update, subject, old_value, new_value})
  end
end
