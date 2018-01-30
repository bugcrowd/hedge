defmodule Hedge.Github do
  def ping(payload) do
    IO.puts("zen: #{payload["zen"]}")
  end

  def pull_request(payload) do
    action = payload["action"]
    sha = payload["pull_request"]["head"]["sha"]
    branch = payload["pull_request"]["head"]["label"]

    # TODO: remove conditional
    cond do
      branch == "bugcrowd:webhook-test" && action == "opened" ->
        opened(sha)
      branch == "bugcrowd:webhook-test" && action == "synchronize" ->
        synchronize(sha)
      true ->
        IO.puts "#{sha}: unsupported action: #{action}"
    end
  end

  defp opened(sha) do
    IO.puts "#{sha}: pull request opened"

    Hedge.Percy.commit(sha)
  end

  # github-speak for pull request branch update with new HEAD
  defp synchronize(sha) do
    IO.puts "#{sha}: pull request synchronized"

    Hedge.Percy.commit(sha)
  end
end
