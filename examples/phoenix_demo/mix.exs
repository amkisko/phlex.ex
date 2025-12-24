defmodule PhoenixDemo.MixProject do
  use Mix.Project

  def project do
    [
      app: :phoenix_demo,
      version: "0.1.0",
      elixir: "~> 1.18",
      elixir_paths: elixir_paths(Mix.env()),
      compilers: Mix.compilers(),
      start_permanent: Mix.env() == :prod,
      aliases: aliases(),
      deps: deps()
    ]
  end

  def application do
    [
      mod: {PhoenixDemo.Application, []},
      extra_applications: [:logger, :runtime_tools]
    ]
  end

  defp elixir_paths(:test), do: ["lib", "test/support"]
  defp elixir_paths(_), do: ["lib"]

  defp deps do
    [
      {:phoenix, "~> 1.7.0"},
      {:phoenix_live_view, "~> 0.20.0"},
      {:phoenix_html, "~> 4.0"},
      {:phoenix_html_helpers, "~> 1.0"},
      {:phoenix_live_reload, "~> 1.2", only: :dev},
      {:gettext, "~> 0.20"},
      {:jason, "~> 1.2"},
      {:plug_cowboy, "~> 2.5"},
      {:phlex, path: "../.."},
      {:style_capsule, path: "../../../style_capsule.ex", override: true},
      {:tailwind, "~> 0.2", runtime: Mix.env() == :dev},
      {:ecto_sql, "~> 3.10"},
      {:ecto_sqlite3, "~> 0.10"}
    ]
  end

  defp aliases do
    [
      setup: ["deps.get", "ecto.setup", "assets.build"],
      "ecto.setup": ["ecto.create", "ecto.migrate", "run priv/repo/seeds.exs"],
      "ecto.reset": ["ecto.drop", "ecto.setup"],
      "assets.build": ["style_capsule.build", "tailwind phoenix_demo"],
      "assets.deploy": ["style_capsule.build", "tailwind phoenix_demo --minify", "phx.digest"]
    ]
  end
end
