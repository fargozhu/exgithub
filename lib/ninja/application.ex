defmodule Ninja.Application do
  @moduledoc "OTP Application specification for Ninja"
  use Application

  def start(_type, _args) do
    children = [
      Plug.Cowboy.child_spec(
        scheme: :http,
        plug: Ninja.Endpoint,
        options: [port: Application.get_env(:ninja, :port)]
      )
    ]  
  
    opts = [strategy: :one_for_one, name: Ninja.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
