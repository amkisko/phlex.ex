defmodule PhoenixDemo.Application do
  @moduledoc false
  use Application

  import Ecto.Query

  @impl true
  def start(_type, _args) do
    children = [
      # Start the Ecto repository
      PhoenixDemo.Repo,
      # Start the PubSub system
      {Phoenix.PubSub, name: PhoenixDemo.PubSub},
      # Start the Endpoint (http/https)
      PhoenixDemoWeb.Endpoint
    ]

    opts = [strategy: :one_for_one, name: PhoenixDemo.Supervisor]

    case Supervisor.start_link(children, opts) do
      {:ok, pid} ->
        # Run seeds after the repo is started
        ensure_seeds()
        {:ok, pid}
      error ->
        error
    end
  end

  defp ensure_seeds do
    # Check if users exist, if not, run seeds
    # Use Task.start to run in background and avoid blocking startup
    Task.start(fn ->
      # Wait a bit for the repo to be fully ready
      Process.sleep(500)

      try do
        user_count = PhoenixDemo.Repo.one(from u in PhoenixDemo.Schemas.User, select: count(u.id))
        if user_count == 0 do
          # No users, run seeds by executing the seed file code directly
          seeds_path = Path.join([File.cwd!(), "priv", "repo", "seeds.exs"])
          if File.exists?(seeds_path) do
            # Read and evaluate the seed file
            seed_code = File.read!(seeds_path)
            Code.eval_string(seed_code, [], file: seeds_path)
            IO.puts("✅ Database seeded successfully on startup!")
          else
            IO.puts("⚠️  Seed file not found at #{seeds_path}")
            IO.puts("   Run 'mix run priv/repo/seeds.exs' manually to seed the database.")
          end
        else
          IO.puts("ℹ️  Database already has #{user_count} user(s), skipping seed.")
        end
      rescue
        e ->
          IO.puts("⚠️  Could not seed database: #{inspect(e)}")
          IO.puts("   Run 'mix run priv/repo/seeds.exs' manually to seed the database.")
      end
    end)
  end

  def config(_config, _key) do
    []
  end
end
