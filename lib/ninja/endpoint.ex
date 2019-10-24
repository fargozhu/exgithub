defmodule Ninja.Endpoint do
  use Plug.Router

  plug(Plug.Logger)
  plug(:match)
  plug(Plug.Parsers, parsers: [:json], json_decoder: Poison)
  plug(:dispatch)

  post "/events" do    
    #{status, body} = process_request(conn.body_params)
    send_resp(conn, 200, %{fname: "jaime", lname: "gomes"})
  end

  match _ do
    send_resp(conn, 404, "oops... Nothing here :(")
  end

  # processes any event triggered through Github webhook
  def process_event(conn) do
    process_request(conn.body_params)
    |> Poison.encode!()
    |> send_response(conn)
  end

  defp send_response(resp, conn), do: send_resp(conn, resp.status, resp.payload)

  # called when a Github issue is created.
  defp process_request(%{"action" => "opened"}) do
    %{
      status: 200,
      payload: %{
        action: "created"
      }
    }
  end

  # called when a Github issue is closed.
  defp process_request(%{"action" => "closed"}) do
    %{
      status: 200,
      payload: %{
        action: "closed"
      }
    }
  end

  # called when a comment is added to a Github issue.
  defp process_request(%{"action" => "created"}) do
    %{
      status: 200,
      payload: %{
        action: "added_comment"
      }
    }
  end

  defp process_request(_event) do
    %{
      status: 500,
      payload: %{
        error: "Expected Payload: { 'action': opened|closed|updated, ... }"
      }
    }
  end


  #def child_spec(opts) do
  #  %{
  #    id: __MODULE__,
  #    start: {__MODULE__, :start_link, [opts]}
  #  }
  #end

  #def start_link(_opts), do: Plug.Cowboy.http(__MODULE__, [])
end
