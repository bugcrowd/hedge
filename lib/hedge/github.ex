defmodule Hedge.Github do
  require Logger

  def ping(payload) do
    Logger.debug "zen: #{payload["zen"]}"
  end

  def pull_request(payload) do
    action = payload["action"]
    sha = payload["pull_request"]["head"]["sha"]
    branch = payload["pull_request"]["head"]["label"]

    case action do
      "opened" ->
        opened(sha)
      "synchronize" ->
        synchronize(sha)
      _ ->
        Logger.warn "#{sha}: unsupported action: #{action}"
    end
  end

  defp opened(sha) do
    Logger.debug "#{sha}: pull request opened"

    Hedge.Percy.commit(sha)
  end

  # github-speak for pull request branch update with new HEAD
  defp synchronize(sha) do
    Logger.debug "#{sha}: pull request synchronized"

    Hedge.Percy.commit(sha)
  end
end
