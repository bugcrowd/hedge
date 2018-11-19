defmodule Hedge.Router do
  require Logger
  use Plug.Router
  alias Hedge.Webhooks

  defmodule CacheBodyReader do
    def read_body(conn, opts) do
      {:ok, body, conn} = Plug.Conn.read_body(conn, opts)
      conn = update_in(conn.assigns[:raw_body], &[body | (&1 || [])])
      {:ok, body, conn}
    end
  end

  plug(Plug.Logger, log: :debug)
  plug(Plug.Parsers, parsers: [:json], body_reader: {CacheBodyReader, :read_body, []}, json_decoder: Poison)
  plug(:match)
  plug(:dispatch)

  get "/" do
    Plug.Conn.send_resp(conn, 200, Poison.encode!(Hedge.Percy.get_processes()))
  end

  post "/hooks" do
    Logger.warn("unsupported webhook event: #{inspect(conn.req_headers)}")
    verify_webhook(:percy, conn)
    Plug.Conn.send_resp(conn, 201, "")
  end

  match _ do
    Plug.Conn.send_resp(conn, 404, "")
  end

  defp verify_webhook(namespace, conn) do
    # See https://github.com/elixir-plug/plug/pull/698 for why this is necessary
    digest = hd(Plug.Conn.get_req_header(conn, "x-#{namespace}-digest"))
    raw_body = conn.assigns[:raw_body]
    hash = :crypto.hmac(:sha256, System.get_env("PERCY_SECRET"), raw_body) |> Base.encode16 |> String.downcase

    unless hash == digest do
      Plug.Conn.send_resp(conn, 403, "")
    end
  end
end

