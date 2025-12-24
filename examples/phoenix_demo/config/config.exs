import Config

config :phoenix_demo, PhoenixDemoWeb.Endpoint,
  url: [host: "localhost"],
  render_errors: [
    formats: [html: PhoenixDemoWeb.ErrorHTML],
    layout: false
  ],
  pubsub_server: PhoenixDemo.PubSub,
  live_view: [signing_salt: "phoenix_demo"]

config :phoenix_demo, PhoenixDemoWeb.Endpoint,
  http: [ip: {127, 0, 0, 1}, port: 4000],
  check_origin: false,
  code_reloader: true,
  debug_errors: true,
  secret_key_base: "phoenix_demo_secret_key_base_for_development_only_change_in_production",
  watchers: [
    tailwind: {Tailwind, :install_and_run, [:phoenix_demo, ~w(--watch)]}
  ]

config :phoenix_demo,
  ecto_repos: [PhoenixDemo.Repo]

config :phoenix_demo, PhoenixDemo.Repo,
  database: Path.expand("../phoenix_demo_dev.db", __DIR__),
  pool_size: 5,
  show_sensitive_data_on_connection_error: true

config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

config :phoenix, :json_library, Jason
config :phoenix, :stacktrace_depth, 20
config :phoenix, :plug_init_mode, :runtime

# Configure tailwind
config :tailwind,
  version: "4.1.12",
  phoenix_demo: [
    args: ~w(
      --input=assets/css/app.css
      --output=priv/static/assets/css/app.css
    ),
    cd: Path.expand("..", __DIR__)
  ]

# Configure StyleCapsule to output to priv/static/assets/css (like Tailwind)
config :style_capsule,
  output_dir: "priv/static/assets/css"
