defmodule Hedge.Webhooks do
  require Logger
  alias Hedge.Github

  def valid_digest?(digest, raw_body) do
    hash =
      :crypto.hmac(:sha256, System.get_env("PERCY_WEBHOOK_SECRET"), raw_body)
      |> Base.encode16()
      |> String.downcase()

    hash == digest
  end

  def handle_ping(payload) do
    Logger.info("handle ping: #{inspect(payload)}")
  end

  def handle_build_created(payload) do
    Logger.info("handle_build_created: #{inspect(payload)}")

    Github.update_status(
      metadata(payload)[:sha],
      "pending",
      "Percy build ##{metadata(payload)[:build]} is processing",
      metadata(payload)[:url]
    )
  end

  def handle_build_approved(payload) do
    Logger.info("handle_build_approved: #{inspect(payload)}")

    Github.update_status(
      metadata(payload)[:sha],
      "success",
      "Percy build ##{metadata(payload)[:build]} has been approved",
      metadata(payload)[:url]
    )
  end

  def handle_build_finished(payload) do
    Logger.info("handle_build_finished: #{inspect(payload)}")

    Github.update_status(
      metadata(payload)[:sha],
      "failure",
      "Percy build ##{metadata(payload)[:build]} requires approval",
      metadata(payload)[:url]
    )
  end

  defp metadata(payload) do
    builds = payload["included"] |> Enum.find(fn s -> s["type"] == "builds" end)

    unless builds["attributes"]["branch"] == "test-percy-build" do
      raise "unsupported branch"
    end

    commits =
      payload["included"] |> Enum.find(fn s -> s["type"] == "commits" end)

    metadata = %{
      build: payload["data"]["relationships"]["build"]["data"]["id"],
      url: builds["attributes"]["web-url"],
      sha: commits["attributes"]["sha"]
    }

    Logger.info("builds: #{inspect(builds)}")
    Logger.info("commits: #{inspect(commits)}")
    Logger.info("metadata: #{inspect(metadata)}")

    metadata
  end
end
