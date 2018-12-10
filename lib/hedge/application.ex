defmodule Hedge.Application do
  @moduledoc false

  require Logger
  use Application

  def start(_type, _args) do
    import Supervisor.Spec, warn: false

    unless Mix.env() == :prod do
      Envy.load([".env"])
    end

    port =
      case System.get_env("PORT") do
        # default port
        port when is_binary(port) ->
          String.to_integer(port)

        nil ->
          nil
      end

    children = [
      Plug.Cowboy.child_spec(
        scheme: :http,
        plug: Hedge.Router,
        options: [port: port || 4000]
      )
    ]

    Logger.info("Hedge running on port #{port}")
    Logger.info("Percy project is #{System.get_env("PERCY_PROJECT")}")
    Logger.info("Github repo is #{System.get_env("GITHUB_REPO")}")
    Logger.info("Github user is #{System.get_env("GITHUB_USER")}")

    Supervisor.start_link(
      children,
      strategy: :one_for_one,
      name: Hedge.Supervisor
    )
  end
end
