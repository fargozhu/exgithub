import Config

config :exgithub,
  port: String.to_integer(System.fetch_env!("PORT")),
  secret_token: System.fetch_env!("SECRET_TOKEN"),
  jira_base_url: System.fetch_env!("JIRA_BASE_URL"),
  jira_auth_token: System.fetch_env!("JIRA_AUTH_TOKEN"),
  github_trigger_label: "SUSE"

config :exgithub, port: 80
