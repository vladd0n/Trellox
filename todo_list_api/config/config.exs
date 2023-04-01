# This file is responsible for configuring your application
# and its dependencies with the aid of the Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
import Config

config :todo_list_api,
  ecto_repos: [TodoListApi.Repo]

# Configures the endpoint
config :todo_list_api, TodoListApiWeb.Endpoint,
  url: [host: "localhost"],
  render_errors: [
    formats: [json: TodoListApiWeb.ErrorJSON],
    layout: false
  ],
  pubsub_server: TodoListApi.PubSub,
  live_view: [signing_salt: "8pBdBe1u"]

# Configures the mailer
#
# By default it uses the "Local" adapter which stores the emails
# locally. You can see the emails in your browser, at "/dev/mailbox".
#
# For production it's recommended to configure a different adapter
# at the `config/runtime.exs`.
config :todo_list_api, TodoListApi.Mailer, adapter: Swoosh.Adapters.Local

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Configures Guardian
config :guardian, TodoListApi.Guardian,
  issuer: "todo_list_api",
  secret_key: "3bI+cenQygZ9iSbTAs/AgLvt66TvOLkhx5A/jZQF1LTQcfT950wTehMglDmMoqV"

config :todo_list_api, TodoListApi.Auth.Authenticator,
  issuer: "todo_list_api",
  secret_key: "3bI+cenQygZ9iSbTAs/AgLvt66TvOLkhx5A/jZQF1LTQcfT950wTehMglDmMoqV",
  serializer: TodoListApi.Auth.GuardianSerializer

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{config_env()}.exs"

# Guardian configuration
config :todo_list_api, TodoListApi.Guardian,
  issuer: "todo_list_api",
  secret_key: "my_very_secret_key"
