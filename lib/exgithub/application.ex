defmodule ExGitHub.Application do
  @moduledoc "OTP Application specification for ExGitHub"

  use Application
  require Logger

  def start(_type, _args) do
    build_app_env()

    port =
      get_port(
        Application.get_env(:exgithub, :http_port),
        String.length(Application.get_env(:exgithub, :http_port))
      )

    children = [
      Plug.Cowboy.child_spec(
        scheme: :http,
        plug: ExGitHub.Endpoint,
        options: [port: http_port]
      )
    ]

    opts = [strategy: :one_for_one, name: ExGitHub.Supervisor]

    Logger.info("starting application on port #{http_port}")

    Supervisor.start_link(children, opts)
  end

  defp build_app_env() do
    Logger.info("setting app variables")

    http_port = System.get_env("HTTP_PORT")
    secret_token = System.get_env("SECRET_TOKEN")
    jira_base_url = System.get_env("JIRA_BASE_URL")
    jira_auth_token = System.get_env("JIRA_AUTH_TOKEN")
    label = System.get_env("LABEL")

    Logger.info("Label: #{label}, URL: #{jira_base_url}:#{http_port}")

    Application.put_env(:exgithub, :http_port, http_port)
    Application.put_env(:exgithub, :secret_token, secret_token)
    Application.put_env(:exgithub, :jira_base_url, jira_base_url)
    Application.put_env(:exgithub, :jira_auth_token, jira_auth_token)
    Application.put_env(:exgithub, :github_trigger_label, label)
  end

  defp get_port(port, length) when not is_nil(port) and length > 0, do: String.to_integer(port)
  defp get_port(_, _), do: 4000
end
