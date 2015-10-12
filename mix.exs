defmodule FlowerPower.Mixfile do
  use Mix.Project

  def project do
    [app: :flower_power,
     version: "0.0.1",
     elixir: "~> 1.0",
     description: "Api client for flower power cloud api",
     package: package,
     deps: deps]
  end

  # Configuration for the OTP application
  #
  # Type `mix help compile.app` for more information
  def application do
    [applications: [:logger, :httpoison, :tzdata]]
  end

  defp pack do
    [files: ["lib", "priv", "mix.exs", "README.md"],
    contributors:["Lee Bryant"],
    licenses: ["MIT"],
    links: %{ "GitHub": "https://github.com/Korbin73/FlowerPower" } ]
  end

  defp deps do
    [  
      {:httpoison, "~> 0.7.2"},
      {:poison, "~> 1.5"},
      {:timex, "~> 0.19.0"},
      {:shouldi, only: :test}
    ]
  end
end