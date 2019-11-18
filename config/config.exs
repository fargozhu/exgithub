use Mix.Config

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

config :exgithub,
  secret_token: System.get_env("SECRET_TOKEN"),
  jira_base_url: System.get_env("JIRA_BASE_URL"),
  jira_auth_token: System.get_env("JIRA_AUTH_TOKEN"),
  github_trigger_label: "SUSE"
#import_config "#{Mix.env()}.exs"
