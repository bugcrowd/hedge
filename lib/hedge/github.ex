defmodule Hedge.Github do
  require Logger

  def update_status(sha, status, description, url \\ nil) do
    # check the status before posting a new one, to avoid the 1000 status limit
    if status_has_changed(sha, status) do
      Logger.debug("#{sha}: posting #{status} status")

      post_update(sha, status, description, url)
    else
      Logger.debug("#{sha}: not updating status")
    end
  end

  defp status_has_changed(sha, status) do
    latest =
      GithubClient.get(
        "/repos/#{System.get_env("GITHUB_REPO")}/commits/#{sha}/statuses"
      ).body
      |> Enum.find(fn s -> s["context"] == "hedge/percy" end)

    Logger.debug("#{sha}: latest github status is #{latest["state"]}")

    # if the latest state is the same as our updated one,
    # then short circuit and skip posting the update
    latest["state"] != status
  end

  defp post_update(sha, status, description, url) do
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
