defmodule HedgeTest do
  use ExUnit.Case
  doctest Hedge

  test "greets the world" do
    assert Hedge.hello() == :world
  end
end
