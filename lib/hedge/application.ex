defmodule Hedge.Application do
  @moduledoc false

  require Logger
  use Application

  def start(_type, _args) do
    import Supervisor.Spec, warn: false

    unless Mix.env() == :prod do
      Envy.load([".env"])
    end

    children = [
      worker(Hedge.Percy, []),
      Plug.Adapters.Cowboy.child_spec(
        :http,
        Hedge.Router,
        [],
        port: 4000
      )
    ]

    opts = [strategy: :one_for_one, name: Hedge.Supervisor]
    Logger.info("Hedge running on port 4000")
    Logger.info("Percy project is #{System.get_env("PERCY_PROJECT")}")
    Logger.info("Percy API key is #{System.get_env("PERCY_API_KEY")}")

    Supervisor.start_link(children, opts)
  end
end
