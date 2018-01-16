defmodule Hedge.Router do
  use Plug.Router

  plug Plug.Logger, log: :debug
  plug Plug.Parsers,
    parsers: [:json],
    json_decoder: Poison
  plug :match
  plug :dispatch

  get "/" do
    Plug.Conn.send_resp(conn, 200, "")
  end

  post "/hooks" do
    type = Plug.Conn.get_req_header(conn, "x-github-event")
    IO.puts("event: #{type}")

    case hd(type) do
      "ping"         -> Hedge.Github.ping(conn.body_params)
      "pull_request" -> Hedge.Github.pull_request(conn.body_params)
      _              -> IO.puts("unsupported webhook event: #{type}")
    end

    Plug.Conn.send_resp(conn, 201, "")
  end

  match _ do
    Plug.Conn.send_resp(conn, 404, "")
  end
end
