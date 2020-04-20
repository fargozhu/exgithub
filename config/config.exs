use Mix.Config

# Our Logger general configuration
config :logger,
  backends: [:console],
  compile_time_purge_level: :debug


# Our Console Backend-specific configuration
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# import_config "#{Mix.env()}.exs"
