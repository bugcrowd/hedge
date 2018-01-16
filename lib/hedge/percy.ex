defmodule Hedge.Percy do
  def commit(sha) do
    task = Task.async fn ->
      # poll percy
      :ok
    end

    result = Task.await(task)
  end
end
