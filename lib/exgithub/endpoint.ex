defmodule ExGitHub.Endpoint do
  @moduledoc """
  This is the ExGitHub Endpoint definition
  """
  require Logger
  use Plug.Router

  alias ExGitHub.Plug.{SignatureVerification, CacheBodyReader}

  @secret_token Application.get_env(:exgithub, :secret_token)

  plug :match
  plug Plug.Logger
  plug Plug.RequestId
  plug Plug.Parsers,
    parsers: [:json],
    body_reader: {CacheBodyReader, :read_body, []},
    json_decoder: Jason
  plug SignatureVerification, header: "x-hub-signature", secret: @secret_token
  plug :dispatch

  get "/health" do
    send_resp(conn, 200, "OK")
  end

  post "/events" do
    {:ok, resp} = process_request(conn.body_params)
    resp
    |> send_response(conn)
  end


  match _ do
    send_resp(conn, 404, "oops... Nothing here :(")
  end

  defp send_response(resp, conn) do
    conn
    |> put_resp_content_type("application/json")
    |> send_resp(resp.status, Poison.encode!(resp))
  end

  # called when a Github issue is created.
  defp process_request(payload = %{"action" => "opened"}) do
    Logger.debug("processing request from github...")
    response = ExGitHub.Controller.create(payload)

    {:ok,
     %{
       status: response.status,
       action: "created",
       payload: response.payload
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
