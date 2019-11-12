defmodule Gira.MixProject do
  use Mix.Project

  def project do
    [
      app: :gira,
      version: "0.3.0",
      elixir: "~> 1.9",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      description: description(),
      package: package()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger]
      # mod: {Gira.Application, [env: Mix.env]}
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:httpoison, "~> 1.6"},
      {:poison, "~> 4.0"},
      {:jason, "~> 1.1"},
      {:ex_doc, ">= 0.0.0", only: :dev, runtime: false}
    ]
  end

  defp description() do
    "Gira is a Jira client library for the fews."
  end

  defp package() do
    [
      files: ["lib", "mix.exs", "README.md", "LICENSE*", ".formatter.exs"],
      maintainers: ["Jaime Gomes"],
      licenses: ["Apache 2.0"],
      links: %{"GitHub" => "https://github.com/fargozhu/gira"}
    ]
  end
end
