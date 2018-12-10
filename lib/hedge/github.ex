defmodule Hedge.Github do
  require Logger

  def update_status(sha, status, description, url \\ nil) do
    GithubClient.post(
      "/repos/#{System.get_env("GITHUB_REPO")}/statuses/#{sha}",
      body:
        Poison.encode!(%{
          state: status,
          target_url: url,
          description: description,
          context: "hedge/percy"
        })
    )
  end
end
