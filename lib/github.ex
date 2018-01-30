defmodule Github do
  def update_status(sha, status, description, url \\ nil) do
    # TODO: check the status before posting a new one,
    # to avoid the 1000 status limit

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
