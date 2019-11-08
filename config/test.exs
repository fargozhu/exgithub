use Mix.Config

config :exgithub, port: 4002

config :exgithub,
  secret_token: System.fetch_env!("SECRET_TOKEN"),
  jira_base_url: System.fetch_env!("JIRA_BASE_URL"),
  jira_auth_token: System.fetch_env!("JIRA_AUTH_TOKEN")

config :logger,
  level: :debug,
  truncate: :infinity
