defmodule Hedge.Router do
  require Logger
  use Plug.Router
  alias Hedge.Webhooks

  plug(Plug.Logger, log: :debug)
  plug(Plug.Parsers, parsers: [:json], json_decoder: Poison)
  plug(:match)
  plug(:dispatch)

  get "/" do
    Plug.Conn.send_resp(conn, 200, "")
  end

  post "/hooks" do
    type = Plug.Conn.get_req_header(conn, "x-github-event")
    Logger.debug("webhook event: #{type}")

    case hd(type) do
      "ping" -> Webhooks.handle_ping(conn.body_params)
      "pull_request" -> Webhooks.handle_pull_request(conn.body_params)
      _ -> Logger.warn("unsupported webhook event: #{type}")
    end

    Plug.Conn.send_resp(conn, 201, "")
  end

  match _ do
    Plug.Conn.send_resp(conn, 404, "")
  end
end
