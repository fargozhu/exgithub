defmodule ExGitHub.EndpointTest do
  use ExUnit.Case, async: true
  use Plug.Test

  @opts ExGitHub.Endpoint.init([])

  test "it returns pong" do
    # Create a test connection
    conn = conn(:get, "/ping")

    # Invoke the plug
    conn = ExGitHub.Endpoint.call(conn, @opts)

    # Assert the response and status
    assert conn.state == :sent
    assert conn.status == 200
    assert conn.resp_body == "pong"
  end

  @tag
  test "it returns 202 when creating a new Jira issue" do
    conn = conn(:post, "/events", %{action: "opened"})
    conn = ExGitHub.Endpoint.call(conn, @opts)

    assert conn.state == :sent
    assert conn.status == 200
  end

  @tag
  test "it returns 200 when closing a Jira issue" do
    conn = conn(:post, "/events", %{action: "closed"})
    conn = ExGitHub.Endpoint.call(conn, @opts)

    assert conn.state == :sent
    assert conn.status == 200
  end

  @tag
  test "it returns 200 when adding a comment" do
    conn = conn(:post, "/events", %{action: "created"})
    conn = ExGitHub.Endpoint.call(conn, @opts)

    assert conn.state == :sent
    assert conn.status == 200
  end

  @tag
  test "it returns 400 for an invalid Github action" do
    conn = conn(:post, "/events", %{action: "whatever"})
    conn = ExGitHub.Endpoint.call(conn, @opts)
    decoded = Poison.decode!(conn.resp_body)

    assert conn.state == :sent
    assert conn.status == 400
    assert decoded["error"] == "invalid action"
  end

  @tag
  test "it returns 400 for an invalid content request" do
    conn = conn(:post, "/events", %{fake_news: "whatever"})
    conn = ExGitHub.Endpoint.call(conn, @opts)
    decoded = Poison.decode!(conn.resp_body)

    assert conn.state == :sent
    assert conn.status == 400
    assert decoded["error"] == "invalid content"
  end

  test "it returns 404" do
    conn = conn(:post, "/fake")
    conn = ExGitHub.Endpoint.call(conn, @opts)

    assert conn.state == :sent
    assert conn.status == 404
  end
end
