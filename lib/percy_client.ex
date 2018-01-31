defmodule PercyClient do
  def poll(sha) do
    response =
      HTTPotion.get(
        "https://percy.io/api/v1/projects/" <>
          "#{System.get_env("PERCY_PROJECT")}/builds?filter[sha]=#{sha}",
        headers: [
          Authorization: "Token #{System.get_env("PERCY_API_KEY")}"
        ]
      )

    case response.status_code do
      200 -> {:ok, attributes(response)}
      _ -> {:err, "Bad response"}
    end
  end

  defp attributes(response) do
    response.body
    |> IO.iodata_to_binary()
    |> Poison.decode!()
    |> Map.get("data")
    |> List.first()
  end
end
