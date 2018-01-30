defmodule Hedge.Percy do
  @polling_freq 15_000 # ms

  def commit(sha) do
    Task.async fn ->
      poll(sha)

      IO.puts "#{sha}: polling complete"
    end
  end

  defp poll(sha) do
    :timer.sleep @polling_freq

    {status, data} = Percy.poll(sha)

    case status do
      :ok  -> parse_response(sha, data)
      :err -> IO.puts "#{sha}: error: #{data}"
    end
  end

  defp parse_response(sha, data) when is_nil(data) do
    IO.puts "#{sha}: no builds yet"

    poll(sha)
  end

  defp parse_response(sha, data) do
    attrs = data["attributes"]
    state = attrs["state"]
    review_state = attrs["review-state"]
    build = attrs["build-number"]

    cond do
      state == "finished" && review_state == "approved" ->
        IO.puts "#{sha}: build #{build} is approved"
      state == "finished" ->
        IO.puts "#{sha}: build #{build} is #{review_state}"
        poll(sha)
      state == "pending" ->
        IO.puts "#{sha}: build #{build} is pending"
        poll(sha)
      true ->
        IO.puts "#{sha}: build #{build} is in an unknown state"
        IO.puts "#{sha}: state is #{state}, review state is #{review_state}"
    end
  end
end
