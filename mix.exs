defmodule Hedge.Mixfile do
  use Mix.Project

  def project do
    [
      app: :hedge,
      version: "0.1.0",
      elixir: "~> 1.5",
      start_permanent: Mix.env == :prod,
      deps: deps()
    ]
  end

  def application do
    [
      extra_applications: [:logger],
      mod: {Hedge.Application, []}
    ]
  end

  defp deps do
    [
      {:cowboy, "~> 1.1.2"},
      {:plug, "~> 1.3.5"},
      {:poison, "~> 3.1.0"},
      {:envy, "~> 1.1.1"},
      {:httpotion, "~> 3.0.2"}
    ]
  end
end
