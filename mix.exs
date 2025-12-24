defmodule Phlex.MixProject do
  use Mix.Project

  @version "0.1.0"
  @source_url "https://github.com/amkisko/phlex.ex"

  def project do
    [
      app: :phlex,
      version: @version,
      elixir: "~> 1.18",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      package: package(),
      description: description(),
      docs: docs(),
      aliases: aliases(),
      preferred_cli_env: [
        coveralls: :test,
        "coveralls.json": :test,
        "coveralls.html": :test,
        "test.all": :test,
        credo: :test,
        dialyzer: :test
      ],
      dialyzer: [
        plt_add_apps: [:mix, :benchee],
        ignore_warnings: "dialyzer.ignore-warnings"
      ],
      test_coverage: [
        tool: ExCoveralls
      ]
    ]
  end

  def application do
    [
      extra_applications: [:logger]
    ]
  end

  defp deps do
    [
      # Phoenix dependencies (optional, for Phoenix integration)
      {:phoenix, "~> 1.7", optional: true},
      {:phoenix_live_view, "~> 0.20", optional: true},
      {:phoenix_html, "~> 4.0", optional: true},
      {:plug, "~> 1.14", optional: true},
      {:plug_cowboy, "~> 2.6", optional: true},

      # StyleCapsule (optional, for CSS scoping)
      {:style_capsule, "~> 0.5", optional: true},

      # Testing
      {:stream_data, "~> 1.0", only: :test},

      # Code quality
      {:credo, "~> 1.7", only: [:dev, :test], runtime: false},
      {:dialyxir, "~> 1.4", only: [:dev, :test], runtime: false},
      {:ex_doc, "~> 0.31", only: :dev, runtime: false},
      {:excoveralls, "~> 0.18", only: :test, runtime: false},
      {:benchee, "~> 1.0", only: :dev, runtime: false},
      {:benchee_html, "~> 1.0", only: :dev, runtime: false}
    ]
  end

  defp package do
    [
      maintainers: ["Andrei Makarov"],
      licenses: ["MIT"],
      links: %{
        "GitHub" => @source_url,
        "Changelog" => "#{@source_url}/blob/main/CHANGELOG.md"
      },
      files: ~w(
        lib mix.exs README.md CHANGELOG.md LICENSE.md .formatter.exs
        benchmarks/README.md
      )
    ]
  end

  defp description do
    """
    Object-oriented web views in Elixir. Build HTML, SVG, and other markup views
    using Elixir's functional programming paradigm with component-based architecture.
    """
  end

  defp docs do
    [
      main: "readme",
      source_url: @source_url,
      extras: [
        "README.md",
        "CHANGELOG.md",
        "CONTRIBUTING.md",
        "LICENSE.md"
      ]
    ]
  end

  defp aliases do
    [
      "test.all": ["test", "credo", "dialyzer"],
      quality: ["format --check-formatted", "credo --strict", "dialyzer", "test"],
      "quality.fix": ["format", "credo --strict"],
      ci: ["test", "credo", "dialyzer"],
      bench: ["phlex.bench"]
    ]
  end
end
