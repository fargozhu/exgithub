defmodule ExGitHub.Application do
  @moduledoc "OTP Application specification for ExGitHub"

  use Application
  require Logger

  def start(_type, _args) do
    build_app_env()

    port =
      get_port(
        Application.get_env(:exgithub, :port),
        String.length(Application.get_env(:exgithub, :port))
      )

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
    Application.put_env(:exgithub, :port, System.get_env("PORT"))
    Application.put_env(:exgithub, :secret_token, System.get_env("SECRET_TOKEN"))
    Application.put_env(:exgithub, :jira_base_url, System.get_env("JIRA_BASE_URL"))
    Application.put_env(:exgithub, :jira_auth_token, System.get_env("JIRA_AUTH_TOKEN"))
    Application.put_env(:exgithub, :github_trigger_label, System.get_env("LABEL"))
  end

  defp get_port(port, length) when not is_nil(port) and length > 0, do: String.to_integer(port)
  defp get_port(_, _), do: 80
end
