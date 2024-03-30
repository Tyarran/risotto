defmodule Risotto.MixProject do
  use Mix.Project

  def project do
    [
      app: :risotto,
      version: "0.1.0",
      elixir: "~> 1.15",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      aliases: aliases()
      # test_coverage: [],
    ]
  end

  def aliases do
    [
      quality: [
        "compile --force --warnings-as-errors",
        "credo --strict",
        "sobelow -i XSS.Raw,Traversal --verbose --exit Low --skip",
        "dialyzer",
        "test --cover --force"
      ]
    ]
  end

  def cli do
    [
      preferred_envs: [
        test: :test,
        quality: :test
      ]
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:credo, "~> 1.7", only: [:dev, :test], runtime: false},
      {:dialyxir, "~> 1.4", only: [:dev, :test], runtime: false},
      {:sobelow, "~> 0.13", only: [:dev, :test], runtime: false}
      # {:dep_from_hexpm, "~> 0.3.0"},
      # {:dep_from_git, git: "https://github.com/elixir-lang/my_dep.git", tag: "0.1.0"}
    ]
  end
end
