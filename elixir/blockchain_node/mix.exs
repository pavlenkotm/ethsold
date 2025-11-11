defmodule BlockchainNode.MixProject do
  use Mix.Project

  def project do
    [
      app: :blockchain_node,
      version: "0.1.0",
      elixir: "~> 1.14",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      description: "Ethereum blockchain node interface in Elixir",
      package: package()
    ]
  end

  def application do
    [
      extra_applications: [:logger, :crypto],
      mod: {BlockchainNode.Application, []}
    ]
  end

  defp deps do
    [
      {:ethereumex, "~> 0.10.0"},
      {:jason, "~> 1.4"},
      {:httpoison, "~> 2.0"},
      {:ex_keccak, "~> 0.7.0"},
      {:ex_doc, "~> 0.30", only: :dev, runtime: false},
      {:credo, "~> 1.7", only: [:dev, :test], runtime: false}
    ]
  end

  defp package do
    [
      licenses: ["MIT"],
      links: %{"GitHub" => "https://github.com/pavlenkotm/ethsold"}
    ]
  end
end
