defmodule ExGitHub.Endpoint do
  @moduledoc """
  This is the ExGitHub Endpoint definition
  """
  use Plug.Router

  plug(Plug.Logger)
  plug(:match)
  plug(Plug.Parsers, parsers: [:json], json_decoder: Poison)
  plug(:dispatch)

  get "/ping" do
    send_resp(conn, 200, "pong")
  end

  @doc """
  This resource will process all the Github webhooks events related with issues
  """
  post "/events" do
    github_event = Parser.parse_event(conn.body_params)
    IO.inspect github_event
    
    {:ok, resp} = process_request(conn.body_params)

    resp
    |> send_response(conn)
  end

  match _ do
    send_resp(conn, 404, "oops... Nothing here :(")
  end

  defp send_response(resp, conn), do: send_resp(conn, resp.status, Poison.encode!(resp.payload))

  # called when a Github issue is created.
  defp process_request(payload = %{"action" => "opened"}) do    
    {:ok,
     %{
       status: 200,
       payload: %{
         action: "created"
       }
     }}
  end

  # called when a Github issue is closed.
  defp process_request(%{"action" => "closed"}) do
    {:ok,
     %{
       status: 200,
       payload: %{
         action: "closed"
       }
     }}
  end

  # called when a comment is added to a Github issue.
  defp process_request(%{"action" => "created"}) do
    {:ok,
     %{
       status: 200,
       payload: %{
         action: "added_comment"
       }
     }}
  end

  defp process_request(%{"action" => _}) do
    {:ok,
     %{
       status: 400,
       payload: %{
         error: "invalid action"
       }
     }}
  end

  defp process_request(_event) do
    {:ok,
     %{
       status: 400,
       payload: %{
         error: "invalid content"
       }
     }}
  end

  # def child_spec(opts) do
  #  %{
  #    id: __MODULE__,
  #    start: {__MODULE__, :start_link, [opts]}
  #  }
  # end

  # def start_link(_opts), do: Plug.Cowboy.http(__MODULE__, [])
end
