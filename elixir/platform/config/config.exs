# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
use Mix.Config

config :platform,
  ecto_repos: [Platform.Repo]

config :mnesia,
  dir: '.mnesia/#{Mix.env()}/#{node()}'

# Configures the endpoint
config :platform, PlatformWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "WQtNI0FlFcC6te3W90NuZFneC5LbYZSzWw2bwVHDgHP/AKD0obNBHgTE1+cvPnQm",
  render_errors: [view: PlatformWeb.ErrorView, accepts: ~w(html json), layout: false],
  pubsub_server: Platform.PubSub,
  live_view: [signing_salt: "LBXn2d5e"]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env()}.exs"
