# This file is responsible for configuring your application
# and its dependencies with the aid of the Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
import Config

config :hinomix,
  ecto_repos: [Hinomix.Repo],
  generators: [timestamp_type: :utc_datetime]

# Configures the endpoint
config :hinomix, HinomixWeb.Endpoint,
  url: [host: "localhost"],
  adapter: Bandit.PhoenixAdapter,
  render_errors: [
    formats: [json: HinomixWeb.ErrorJSON],
    layout: false
  ],
  pubsub_server: Hinomix.PubSub,
  live_view: [signing_salt: "GFUxOUF0nD0JwQRE"]

# Configures the mailer
#
# By default it uses the "Local" adapter which stores the emails
# locally. You can see the emails in your browser, at "/dev/mailbox".
#
# For production it's recommended to configure a different adapter
# at the `config/runtime.exs`.
config :hinomix, Hinomix.Mailer, adapter: Swoosh.Adapters.Local

# Configures Elixir's Logger
config :logger, :default_formatter,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

# Configure Oban
config :hinomix, Oban,
  repo: Hinomix.Repo,
  queues: [default: 10, reports: 5, data_cache: 5],
  plugins: [
    Oban.Plugins.Pruner,
    {Oban.Plugins.Cron,
     crontab: [
       {"* * * * *", Hinomix.Jobs.DataCacheJob},
       {"* * * * *", Hinomix.Jobs.ReportIngestionJob}
     ]}
  ]

config :esbuild,
  version: "0.25.0",
  default: [
    args:
      ~w(app.js --bundle --target=es2017 --outdir=../priv/static/assets --public-path=/assets),
    cd: Path.expand("../assets", __DIR__),
    env: %{"NODE_PATH" => Path.expand("../deps", __DIR__)}
  ]

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{config_env()}.exs"
