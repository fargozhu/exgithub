import Config

config :exgithub,
  port: String.to_integer(System.get_env("PORT")),
  secret_token: System.get_env("SECRET_TOKEN"),
  jira_base_url: System.get_env("JIRA_BASE_URL"),
  jira_auth_token: System.get_env("JIRA_AUTH_TOKEN"),
  github_trigger_label: "SUSE"

config :exgithub, port: 8080

config :logger,
  level: :debug,
  truncate: :infinity

