defmodule ExGitHub.Application do
  @moduledoc "OTP Application specification for ExGitHub"

  use Application
  require Logger

  def start(_type, _args) do
    build_app_env()
    port = get_port()

    children = [
      Plug.Cowboy.child_spec(
        scheme: :http,
        plug: ExGitHub.Endpoint,
        options: [port: port]
      )
    ]

    opts = [strategy: :one_for_one, name: ExGitHub.Supervisor]

    Logger.info("starting application on port #{port}")

    Supervisor.start_link(children, opts)
  end

  defp build_app_env() do
    Logger.info("setting app variables")

    port = System.get_env("PORT")
    secret_token = System.get_env("SECRET_TOKEN")
    jira_base_url = System.get_env("JIRA_BASE_URL")
    jira_auth_token = System.get_env("JIRA_AUTH_TOKEN")
    label = System.get_env("LABEL")
    log_level = System.get_env("LOG_LEVEL")

    Logger.info("Label: #{label}, URL: #{jira_base_url}, Log Level: #{log_level}")

    Application.put_env(:exgithub, :port, port)
    Application.put_env(:exgithub, :secret_token, secret_token)
    Application.put_env(:exgithub, :jira_base_url, jira_base_url)
    Application.put_env(:exgithub, :jira_auth_token, jira_auth_token)
    Application.put_env(:exgithub, :github_trigger_label, label)
    Application.put_env(:exgithub, :log_level, log_level)
  end

  defp get_port() do
    case Application.get_env(:exgithub, :port) do
      nil -> 80
      n -> String.to_integer(n)
    end
  end
end
