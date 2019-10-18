defmodule Ninja.Endpoint do
    use Plug.Router    
    alias Ninja.Jira
    
    plug(Plug.Logger)
    # responsible for matching routes
    plug(:match)
    # Using Poison for JSON decoding
    # Note, order of plugs is important, by placing this _after_ the 'match' plug,
    # we will only parse the request AFTER there is a route match.
    plug(Plug.Parsers, parsers: [:json], pass: ["application/json"], json_decoder: Poison)
    # responsible for dispatching responses
    plug(:dispatch)

    get "/ping" do
        send_resp(conn, 200, "pong!")
    end

    post "/event" do            
        { _status, resp } = process_event(conn.body_params)
        conn
        |> put_resp_content_type("application/json")        
        |> send_resp(200, Poison.encode!(resp))
    end    
    
    defp process_event(event = %{ "action" => _ }) do        
        Jira.new(event)
        |> IO.inspect
        |> Jira.process_jira_issue(event)
        |> IO.inspect        
    end

    defp process_event(_event), do: Poison.encode!(%{error: "Expected Payload: { 'action': opened|closed|updated, ... }"})

    match _ do
        send_resp(conn, 404, "Requested page not found!")
    end    
end