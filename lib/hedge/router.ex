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

  post "/hooks" do
    unless Webhooks.valid_digest?(
      hd(Plug.Conn.get_req_header(conn, "x-percy-digest")),
      conn.assigns[:raw_body]
    ) do
      Plug.Conn.send_resp(conn, 403, "")
    end

    type = hd(Plug.Conn.get_req_header(conn, "x-percy-event"))
    Logger.info("webhook event: #{type}")

    response = case type do
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

