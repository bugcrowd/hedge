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

  def get_processes do
    GenServer.call(:percy, {:get})
  end

  ##

  def start_link() do
    GenServer.start_link(__MODULE__, :ok, name: :percy)
  end

  def init(:ok) do
    {:ok, %{}}
  end

  def handle_call({:get}, _, map) do
    {:reply, Map.keys(map), map}
  end

  def handle_cast({:start, sha}, map) do
    task =
      Task.async(fn ->
        PercyPoller.poll(sha)

        Logger.info("#{sha}: polling complete")
      end)

    {:noreply, Map.put(map, sha, task.pid)}
  end

  def handle_cast({:stop, sha}, map) do
    Logger.info("#{sha}: stopping poll")

    pid = Map.get(map, sha)

    unless is_nil(pid) do
      Logger.warn("#{sha}: killing process")
      Process.exit(pid, "stopping poll")
    end

    {:noreply, Map.delete(map, sha)}
  end
end
