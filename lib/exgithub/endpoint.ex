defmodule ExGitHub.Endpoint do
  @moduledoc """
  This is the ExGitHub Endpoint definition
  """
  require Logger
  use Plug.Router

  alias ExGitHub.Plug.{SignatureVerification, CacheBodyReader}

  @secret_token Application.get_env(:exgithub, :secret_token)


  plug(:match)
  plug(Plug.Logger)
  plug(Plug.RequestId)

  plug(Plug.Parsers,
    parsers: [:json],
    body_reader: {CacheBodyReader, :read_body, []},
    json_decoder: Jason
  )

  plug(SignatureVerification,
    header: "x-hub-signature",
    secret: @secret_token,
    mount: "/v1/events"
  )

  plug(:dispatch)

  get "/health" do
    Logger.info("/health endpoint called")
    send_resp(conn, 200, "OK")
  end

  post "/v1/events" do
    Logger.info("/v1/events endpoint called")
    process_request(conn.body_params)
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

  # called when a label is added to a Github issue.
  defp process_request(payload = %{"action" => "labeled"}) do
    Logger.debug("github action...labeled")
    ExGitHub.Controller.labeled_flow(payload)
  end

    # called when a label is removed from a Github issue.
  defp process_request(payload = %{"action" => "unlabeled"}) do
    Logger.debug("github action...unlabeled")
    #response = ExGitHub.Controller.close(payload)

    {:ok,
      %{
        status: "response.status",
        action: "created",
        payload: "response.payload"
      }}
  end


  defp process_request(%{"action" => _}) do
    Logger.debug("github action not supported")

    {:ok,
     %{
       status: 400,
       payload: %{
         error: "invalid action"
       }
     }}
  end

  defp process_request(_event) do
    Logger.debug("invalid github payload")

    {:ok,
     %{
       status: 400,
       payload: %{
         error: "invalid content"
       }
     }}
  end
end
