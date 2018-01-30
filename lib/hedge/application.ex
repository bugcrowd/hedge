defmodule Hedge.Application do
  @moduledoc false

  require Logger
  use Application

  def start(_type, _args) do
    unless Mix.env == :prod do
      Envy.load([".env"])
    end

    children = [
      Plug.Adapters.Cowboy.child_spec(
        :http,
        Hedge.Router,
        [],
        port: 4000
      )
    ]

    opts = [strategy: :one_for_one, name: Hedge.Supervisor]
    Logger.info "hedge running on port 4000"
    Logger.info "percy project is #{System.get_env("PERCY_PROJECT")}"
    Logger.info "percy api key is #{System.get_env("PERCY_API_KEY")}"

    Supervisor.start_link(children, opts)
  end
end
