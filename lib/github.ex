defmodule Github do
  require Logger

  def update_status(sha, status, description, url \\ nil) do
    # check the status before posting a new one, to avoid the 1000 status limit
    unless check_status(sha, status) do
      Logger.debug "#{sha}: posting #{status} status"
      post_update(sha, status, description, url)
    end
  end

  defp check_status(sha, status) do
    latest = HTTPotion.get(
      "https://api.github.com/repos/#{System.get_env("GITHUB_REPO")}/commits/#{sha}/statuses",
      headers: [
        "User-Agent": "Hedge"
      ],
      basic_auth: {
        System.get_env("GITHUB_USER"),
        System.get_env("GITHUB_ACCESS_TOKEN")
      }
    ).body
    |> Poison.decode!
    |> Enum.find(fn(s) -> s["context"] == "hedge/percy" end)

    Logger.debug "#{sha}: latest github status is #{latest["state"]}"

    # if the latest state is the same as our updated one,
    # then short circuit and skip posting the update
    latest["state"] == status
  end

  defp post_update(sha, status, description, url) do
    HTTPotion.post(
      "https://api.github.com/repos/#{System.get_env("GITHUB_REPO")}/statuses/#{sha}",
      body: Poison.encode!(%{
        state: status,
        target_url: url,
        description: description,
        context: "hedge/percy"
      }),
      headers: [
        "User-Agent": "Hedge"
      ],
      basic_auth: {
        System.get_env("GITHUB_USER"),
        System.get_env("GITHUB_ACCESS_TOKEN")
      }
    )
  end
end
