#!/usr/bin/env elixir

Mix.install([])

defmodule ReleaseScript do
  @moduledoc """
  Release script that ensures quality, runs tests, and publishes to Hex.
  Similar to the Ruby version's usr/bin/release.rb and style_capsule.ex's release.exs
  """

  def run do
    IO.puts("\n🔍 Running quality checks...\n")

    # Change to project directory
    project_dir = Path.expand(__DIR__ <> "/../../")
    File.cd!(project_dir)

    # Run formatter
    IO.puts("📝 Formatting code...")
    unless run_command("mix format --check-formatted") do
      IO.puts("⚠️  Code is not formatted. Running formatter...")
      run_command("mix format")
    end

    # Run Credo
    IO.puts("\n🔍 Running Credo (code analysis)...")
    unless run_command("mix credo --strict") do
      IO.puts("❌ Credo found issues. Please fix them before releasing.")
      System.halt(1)
    end

    # Run Dialyzer
    IO.puts("\n🔍 Running Dialyzer (type checking)...")
    unless run_command("mix dialyzer") do
      IO.puts("⚠️  Dialyzer found issues. Review them before releasing.")
    end

    # Run tests
    IO.puts("\n🧪 Running tests...")
    unless run_command("MIX_ENV=test mix coveralls.json") do
      IO.puts("❌ Tests failed. Please fix them before releasing.")
      System.halt(1)
    end

    # Check git status
    IO.puts("\n📋 Checking git status...")
    git_status = System.cmd("git", ["status", "--porcelain"], stderr_to_stdout: true)
    if git_status != {"", 0} do
      {output, _} = git_status
      unless String.trim(output) == "" do
        IO.puts("\n❌ Git working directory not clean. Please commit your changes first.")
        IO.puts("Note: mix format may have modified files. Review and commit changes before releasing.")
        System.halt(1)
      end
    end

    # Get version from mix.exs
    version = extract_version_from_file("mix.exs")

    if version do
      package_name = "phlex"
      hex_file = "#{package_name}-#{version}.tar"

      IO.puts("\n📦 Building package...")
      unless run_command("mix hex.build") do
        IO.puts("❌ Failed to build package.")
        System.halt(1)
      end

      IO.puts("\n✅ Ready to release #{hex_file} v#{version}")
      IO.write("Continue? [Y/n] ")
      answer = IO.gets("") |> String.trim()

      unless answer == "Y" || answer == "" do
        IO.puts("Exiting")
        System.halt(0)
      end

      # Publish to Hex
      IO.puts("\n📤 Publishing to Hex...")
      unless run_command("mix hex.publish") do
        IO.puts("❌ Failed to publish to Hex.")
        System.halt(1)
      end

      # Create git tag
      IO.puts("\n🏷️  Creating git tag...")
      run_command("git tag v#{version}")
      run_command("git push --tags")

      # Create GitHub release (if gh CLI is available)
      IO.puts("\n🚀 Creating GitHub release...")
      run_command("gh release create v#{version} --generate-notes", allow_failure: true)

      IO.puts("\n✅ Release complete! v#{version}")
    else
      IO.puts("❌ Could not determine version from mix.exs")
      System.halt(1)
    end
  end

  defp run_command(command, opts \\ []) do
    allow_failure = Keyword.get(opts, :allow_failure, false)

    IO.puts("  → #{command}")

    {output, exit_code} = System.cmd("sh", ["-c", command], stderr_to_stdout: true)

    if exit_code == 0 do
      unless String.trim(output) == "" do
        IO.write(output)
      end
      true
    else
      unless allow_failure do
        IO.write(output)
      end
      false
    end
  end

  defp extract_version_from_file(filename) do
    case File.read(filename) do
      {:ok, content} ->
        # Try to match @version "..." first (module attribute)
        case Regex.run(~r/@version\s+"([^"]+)"/, content) do
          [_, version] -> version
          _ ->
            # Fallback to version: "..." in project list
            case Regex.run(~r/version:\s*"([^"]+)"/, content) do
              [_, version] -> version
              _ -> nil
            end
        end
      _ ->
        nil
    end
  end
end

ReleaseScript.run()
