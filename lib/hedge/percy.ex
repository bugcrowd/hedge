defmodule Hedge.Percy do
  require Logger
  use GenServer
  alias Hedge.PercyPoller

  def start_polling(sha) do
    GenServer.cast(:percy, {:start, sha})
  end

  def stop_polling(sha) do
    GenServer.cast(:percy, {:stop, sha})
  end

  ##

  def start_link() do
    GenServer.start_link(__MODULE__, :ok, name: :percy)
  end

  def init(:ok) do
    {:ok, %{}}
  end

  def handle_cast({:start, sha}, map) do
    pid =
      Task.async(fn ->
        # TODO: abandon the polling after a while
        PercyPoller.poll(sha)

        Logger.debug("#{sha}: polling complete")
      end)

    {:noreply, Map.put(map, sha, pid)}
  end

  def handle_cast({:stop, sha}, map) do
    Logger.debug("#{sha}: stopping poll")

    Process.exit(Map.get(map, sha), "stopping poll")

    {:noreply, Map.delete(map, sha)}
  end
end
