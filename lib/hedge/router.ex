defmodule Hedge.Router do
  require Logger
  use Plug.Router
  alias Hedge.Webhooks

  plug(Plug.Logger, log: :debug)
  plug(Plug.Parsers, parsers: [:json], json_decoder: Poison)
  plug(:match)
  plug(:dispatch)

  post "/hooks" do
    type = Plug.Conn.get_req_header(conn, "x-percy-event")
    Logger.info("webhook event: #{type}")

    response = case hd(type) do
      "ping" -> Webhooks.handle_ping(conn.body_params)
      "build_created" -> Webhooks.handle_build_created(conn.body_params)
      "build_approved" -> Webhooks.handle_build_approved(conn.body_params)
      "build_finished" -> Webhooks.handle_build_finished(conn.body_params)
      _ -> Logger.warn("unsupported webhook event: #{type}")
    end

    if HTTPotion.Response.success?(response) do
      Plug.Conn.send_resp(conn, 201, "")
    else
      Plug.Conn.send_resp(conn, response.status_code, "")
    end
  end

  match _ do
    Plug.Conn.send_resp(conn, 404, "")
  end
end

