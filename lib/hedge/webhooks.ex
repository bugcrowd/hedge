defmodule Hedge.Webhooks do
  require Logger

  def handle_ping(payload) do
    Logger.debug("zen: #{payload["zen"]}")
  end

  def handle_pull_request(payload) do
    action = payload["action"]
    sha = payload["pull_request"]["head"]["sha"]

    case action do
      "opened" ->
        handle_pull_request_opened(sha)

      "closed" ->
        handle_pull_request_closed(sha)

      "synchronize" ->
        handle_pull_request_synchronized(sha)

      _ ->
        Logger.warn("#{sha}: unsupported action: #{action}")
    end
  end

  defp handle_pull_request_opened(sha) do
    Logger.debug("#{sha}: pull request opened")

    Hedge.Percy.start_polling(sha)
  end

  defp handle_pull_request_closed(sha) do
    Logger.debug("#{sha}: pull request closed")

    Hedge.Percy.stop_polling(sha)
  end

  # github-speak for pull request branch update with new HEAD
  defp handle_pull_request_synchronized(sha) do
    Logger.debug("#{sha}: pull request synchronized")

    # TODO: stop_polling for previous SHA
    Hedge.Percy.start_polling(sha)
  end
end
