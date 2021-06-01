# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
use Mix.Config

config :text_based_fps,
  namespace: TextBasedFPS

# Configures the endpoint
config :text_based_fps, TextBasedFPSWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "7EZO0kNZgJjyIK2irIxbPg8TkZT7RdvZ6iopk4qdOH6ekdUW2MuDdtsdKihY2Pzl",
  render_errors: [view: TextBasedFPSWeb.ErrorView, accepts: ~w(html json), layout: false],
  pubsub_server: TextBasedFPS.PubSub,
  live_view: [signing_salt: "A4JtrLwE"]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env()}.exs"
