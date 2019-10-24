defmodule Ninja.EndpointTest do
  use ExUnit.Case, async: true
  use Plug.Test

  @opts Ninja.Endpoint.init([])

  test "it returns pong" do
    # Create a test connection
    conn = conn(:get, "/ping")

    # Invoke the plug
    conn = Ninja.Endpoint.call(conn, @opts)

    # Assert the response and status
    assert conn.state == :sent
    assert conn.status == 200
    assert conn.resp_body == "pong!"
  end

  test "it returns 200 for a 'closed' with a valid 'closed' payload" do
    # Create a test connection
    conn = conn(:post, "/event", %{action: "closed", issue: %{id: "122"}})

    # Invoke the plug
    conn = Ninja.Endpoint.call(conn, @opts)

    # Assert the response
    assert conn.status == 200
  end

  test "it returns 200 for a 'opened' with a valid 'opened' payload" do
    # Create a test connection
    conn = conn(:post, "/event", %{action: "opened"})

    # Invoke the plug
    conn = Ninja.Endpoint.call(conn, @opts)

    # Assert the response
    assert conn.status == 200
  end

  test "it returns 200 for a 'created' with a valid payload" do
    # Create a test connection
    conn = conn(:post, "/event", %{action: "created"})

    # Invoke the plug
    conn = Ninja.Endpoint.call(conn, @opts)

    # Assert the response
    assert conn.status == 200
  end

  test "it returns 404 when no route matches" do
    # Create a test connection
    conn = conn(:get, "/fail")

    # Invoke the plug
    conn = Ninja.Endpoint.call(conn, @opts)

    # Assert the response
    assert conn.status == 404
  end
end
