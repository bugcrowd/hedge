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
    Logger.info("#{sha}: pull request opened")

    Hedge.Percy.start_polling(sha)
  end

  defp handle_pull_request_closed(sha) do
    Logger.info("#{sha}: pull request closed")

    Hedge.Percy.stop_polling(sha)
  end

  defp handle_pull_request_synchronized(sha) do
    Logger.info("#{sha}: pull request synchronized")

    Hedge.Percy.start_polling(sha)
  end
end
