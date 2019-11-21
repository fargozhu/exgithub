use Mix.Config

config :exgithub,
  github_trigger_label: "SUSE",
  port: 4000

config :logger,
  level: :debug,
  truncate: :infinity
