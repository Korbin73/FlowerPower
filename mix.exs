defmodule FlowerPower.Mixfile do
  use Mix.Project

  def project do
    [app: :flower_power,
     version: "0.1.3",
     elixir: "~> 1.0",
     description: "Api client for flower power cloud api",
     package: package,
     deps: deps]
  end

  def application do
    [applications: [:logger, :httpoison, :tzdata]]
  end

  defp package do
    [ files: ["lib", "priv", "mix.exs", "README.md"],
      maintainers: ["Lee Bryant"],
      licenses: ["MIT"],
      links: %{ "GitHub": "https://github.com/Korbin73/FlowerPower" } ]
  end

  defp deps do
    [
      {:httpoison, "~> 0.7.2"},
      {:poison, "~> 1.5"},
      {:timex, "~> 1.0"},
      {:shouldi, "~> 0.3.0", only: :test} 
    ]
  end
end
