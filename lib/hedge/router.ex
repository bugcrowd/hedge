defmodule Hedge.Router do
  use Plug.Router

  plug :match
  plug :dispatch
  plug Plug.Parsers,
    parsers: [:json],
    json_decoder: Poison

  get "/" do
    Plug.Conn.send_resp(conn, 200, "")
  end

  match _ do
    Plug.Conn.send_resp(conn, 404, "")
  end
end
