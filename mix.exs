defmodule DripioCore.MixProject do
  use Mix.Project

  def project do
    [
      app: :dripio_core,
      version: "0.1.0",
      elixir: "~> 1.6",
      start_permanent: Mix.env() == :prod,
      aliases: aliases(),
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger],
      mod:
        {DripioCore.Application,
         [:postgrex, :comeonin, :guardian, :phoenix_pubsub, :syn, :mnesia]}
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      # {:dep_from_hexpm, "~> 0.3.0"},
      # {:dep_from_git, git: "https://github.com/elixir-lang/my_dep.git", tag: "0.1.0"},
      {:ecto, ">=0.0.0"},
      {:ecto_sql, ">=0.0.0"},
      {:ecto_shortuuid, "~> 0.1"},
      {:cowboy, ">=0.0.0"},
      {:comeonin, ">=0.0.0"},
      {:bcrypt_elixir, ">=0.0.0"},
      {:guardian, ">=0.0.0"},
      {:postgrex, ">=0.0.0"},
      {:nanoid, "~> 2.0.2"},
      {:jason, ">=0.0.0"},
      {:bamboo, ">=0.0.0"},
      {:tortoise, ">=0.0.0"},
      {:phoenix_pubsub, "~> 1.0"},
      {:syn, "~> 1.6.3"},
      {:opencensus, "~> 0.9.0", override: true},
      {:opencensus_elixir, "~> 0.2.0"},
      {:opencensus_cowboy, "~> 0.3.0"},
      {:opencensus_zipkin, "~> 0.1.0"},
      {:prometheus_ex, "~> 3.0"},
      {:prometheus_plugs, "~> 1.1"},
      {:opencensus_erlang_prometheus, "~> 0.3.2"},
      {:distillery, "2.0.14"}
    ]
  end

  defp aliases do
    [
      "ecto.setup": ["ecto.create", "ecto.migrate", "run priv/repo/seeds.exs"],
      "ecto.reset": ["ecto.drop", "ecto.setup"],
      test: ["ecto.reset", "test"]
    ]
  end
end
