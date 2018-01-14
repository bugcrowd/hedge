defmodule Hedge.Application do
  @moduledoc false

  use Application

  def start(_type, _args) do
    children = [
      Plug.Adapters.Cowboy.child_spec(
        :http,
        Hedge.Router,
        [],
        port: 4000
      )
    ]

    opts = [strategy: :one_for_one, name: Hedge.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
