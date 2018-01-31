defmodule GithubClient do
  require Logger
  use HTTPotion.Base

  def process_url(url) do
    "https://api.github.com" <> url
  end

  def process_request_headers(headers) do
    auth =
      Base.encode64(
        "#{System.get_env("GITHUB_USER")}:#{
          System.get_env("GITHUB_ACCESS_TOKEN")
        }",
        padding: false
      )

    headers
    |> Keyword.put(:"User-Agent", "Hedge")
    |> Keyword.put(:Authorization, "Basic #{auth}")
  end

  def process_response_body(body) do
    body
    |> IO.iodata_to_binary()
    |> Poison.decode!()
  end
end
