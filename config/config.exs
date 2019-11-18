use Mix.Config

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

config :exgithub,
  port: 80,
  secret_token: System.fetch_env!("SECRET_TOKEN"),
  jira_base_url: System.fetch_env!("JIRA_BASE_URL"),
  jira_auth_token: System.fetch_env!("JIRA_AUTH_TOKEN"),
  github_trigger_label: "SUSE"
#import_config "#{Mix.env()}.exs"
