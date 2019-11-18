use Mix.Config

config :exgithub, port: 4002

config :exgithub,
  secret_token: System.get_env("SECRET_TOKEN"),
  jira_base_url: System.get_env("JIRA_BASE_URL"),
  jira_auth_token: System.get_env("JIRA_AUTH_TOKEN"),
  github_trigger_label: "SUSE"

config :logger,
  level: :debug,
  truncate: :infinity
