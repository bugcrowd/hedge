defmodule Hedge.Github do
  def ping(payload) do
    IO.puts("zen: #{payload["zen"]}")
  end

  def pull_request(payload) do
    action = payload["action"]
    sha = payload["pull_request"]["head"]["sha"]

    statuses_url = payload["pull_request"]["statuses_url"]
    number = payload["number"]
    branch = payload["pull_request"]["head"]["label"]

    IO.puts("PR ##{number} (#{branch}) #{action}")

    case action do
      "opened"       -> opened(sha)
      "synchronize"  -> synchronize(sha)
      _ -> IO.inspect("unsupported pull_request action: #{action}")
    end
  end

  defp opened(sha) do
    IO.puts("created #{sha}")
  end

  # github-speak for pull request branch update with new HEAD
  defp synchronize(sha) do
    IO.puts("synchronized #{sha}")
  end
end
