defmodule ExGitHub.MixProject do
  use Mix.Project

  def project do
    [
      app: :exgithub,
      version: "0.1.0",
      elixir: "~> 1.9",
      package: package(),
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      test_coverage: [tool: ExCoveralls]
      # releases: releases()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger, :plug_cowboy],
      mod: {ExGitHub.Application, []}
    ]
  end

  defp releases do
    [
      exgithub: [
        include_executables_for: [:unix],
        applications: [runtime_tools: :permanent]
      ]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:poison, "~> 4.0"},
      {:jason, "~> 1.1"},
      {:plug_cowboy, "~> 2.0"},
      {:gira, "~> 0.4.1", override: true},
      {:excoveralls, "~> 0.7", only: :test},
      {:mox, "~> 0.5.1", only: [:dev, :test]},
      {:ex_doc, "~> 0.21", only: :dev, runtime: false},
      {:inch_ex, "~>2.0", only: [:dev, :test]},
      {:benchfella, "~> 0.3.3", only: :dev},
      {:distillery, "~> 2.0"}
    ]
  end

  defp package do
    [
      maintainers: ["fargozhu"],
      licenses: ["MIT"],
      links: %{"GitHub" => "https://github.com/calipo/exgithub"}
    ]
  end
end
