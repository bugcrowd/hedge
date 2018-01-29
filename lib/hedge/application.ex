defmodule Hedge.Application do
  @moduledoc false

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
    IO.puts("hedge running on port 4000")
    IO.puts("percy project is #{System.get_env("PERCY_PROJECT")}")
    IO.puts("percy api key is #{System.get_env("PERCY_API_KEY")}")

    Supervisor.start_link(children, opts)
  end
end
