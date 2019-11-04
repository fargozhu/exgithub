defmodule ExGitHub.Application do
  @moduledoc "OTP Application specification for ExGitHub"
  use Application

  def start(_type, _args) do
    children = [
      Plug.Cowboy.child_spec(
        scheme: :http,
        plug: ExGitHub.Endpoint,
        options: [port: Application.get_env(:exgithub, :port)]
      )
    ]

    opts = [strategy: :one_for_one, name: ExGitHub.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
