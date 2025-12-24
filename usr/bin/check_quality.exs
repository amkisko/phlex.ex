#!/usr/bin/env elixir

Mix.install([])

defmodule CheckQualityScript do
  @moduledoc """
  Quality check script that runs all quality assurance tools.
  Similar to style_capsule.ex's check_quality.exs
  """

  def run do
    IO.puts("\n🔍 Running quality checks...\n")

    # Change to project directory
    project_dir = Path.expand(__DIR__ <> "/../../")
    File.cd!(project_dir)

    checks = [
      {"Formatter", "mix format --check-formatted"},
      {"Credo", "mix credo --strict"},
      {"Dialyzer", "mix dialyzer"},
      {"Tests", "mix test"}
    ]

    results =
      Enum.map(checks, fn {name, command} ->
        IO.puts("📝 Running #{name}...")
        IO.puts("  → #{command}")

        {output, exit_code} = System.cmd("sh", ["-c", command], stderr_to_stdout: true)

        if exit_code == 0 do
          unless String.trim(output) == "" do
            IO.write(output)
          end
          IO.puts("✅ #{name} passed\n")
          {name, :ok}
        else
          IO.write(output)
          IO.puts("❌ #{name} failed\n")
          {name, :error}
        end
      end)

    failed = Enum.filter(results, fn {_, status} -> status == :error end)

    if Enum.empty?(failed) do
      IO.puts("✅ All quality checks passed!")
      System.halt(0)
    else
      IO.puts("❌ Some quality checks failed:")
      Enum.each(failed, fn {name, _} -> IO.puts("  - #{name}") end)
      System.halt(1)
    end
  end
end

CheckQualityScript.run()
