defmodule ExGitHub.EndpointTest do
  use ExUnit.Case, async: true
  use Plug.Test

  @opts ExGitHub.Endpoint.init([])
  @github_number :rand.uniform(999)

  test "it returns 200 for health checking" do
    # Create a test connection
    conn = conn(:get, "/health")

    # Invoke the plug
    conn = ExGitHub.Endpoint.call(conn, @opts)

    # Assert the response and status
    assert conn.state == :sent
    assert conn.status == 200
  end

  test "it returns 200 when creating a new Jira issue" do
    request = %{
      action: "labeled",
      issue: %{
        id: 519_124_749,
        number: @github_number,
        url: "https://api.github.com/repos/calipo/elixir_senml/issues/30",
        title: "sadd",
        labels: ["SUSE"],
        state: "open",
        body:
          "**Describe the bug**\r\nA clear and concise description of what the bug is.\r\n\r\n**To Reproduce**\r\nSteps to reproduce the behavior:\r\n1. Go to '...'\r\n2. Click on '....'\r\n3. Scroll down to '....'\r\n4. See error\r\n\r\n**Expected behavior**\r\nA clear and concise description of what you expected to happen.\r\n\r\n**Screenshots**\r\nIf applicable, add screenshots to help explain your problem.\r\n\r\n**Desktop (please complete the following information):**\r\n - OS: [e.g. iOS]\r\n - Browser [e.g. chrome, safari]\r\n - Version [e.g. 22]\r\n\r\n**Smartphone (please complete the following information):**\r\n - Device: [e.g. iPhone6]\r\n - OS: [e.g. iOS8.1]\r\n - Browser [e.g. stock browser, safari]\r\n - Version [e.g. 22]\r\n\r\n**Additional context**\r\nAdd any other context about the problem here.\r\n"
      }
    }

    hmac =
      ExGitHub.Helpers.generate_http_signature(
        Application.get_env(:exgithub, :secret_token),
        Poison.encode!(request)
      )

    conn =
      conn(:post, "/v1/events", Poison.encode!(request))
      |> put_req_header("x-hub-signature", "sha1=#{hmac}")
      |> put_req_header("content-type", "application/json")
      |> ExGitHub.Endpoint.call(@opts)

    resp_decoded = Poison.decode!(conn.resp_body)

    assert conn.state == :sent
    assert conn.status == 200
    assert Map.has_key?(resp_decoded["payload"], "id") == true
  end

  test "it returns 200 when closing a Jira issue" do
    request = %{
      action: "unlabeled",
      issue: %{
        id: 519_124_749,
        number: @github_number,
        labels: ["SUSE"]
      }
    }

    hmac =
      ExGitHub.Helpers.generate_http_signature(
        Application.get_env(:exgithub, :secret_token),
        Poison.encode!(request)
      )

    conn =
      conn(:post, "/v1/events", Poison.encode!(request))
      |> put_req_header("x-hub-signature", "sha1=#{hmac}")
      |> put_req_header("content-type", "application/json")
      |> ExGitHub.Endpoint.call(@opts)

    assert conn.state == :sent
    assert conn.status == 200
  end

  test "it returns 400 for an invalid Github action" do
    request = %{
      action: "unknown",
      issue: %{
        id: 519_124_749,
        number: 30,
        labels: ["SUSE"]
      }
    }

    hmac =
      ExGitHub.Helpers.generate_http_signature(
        Application.get_env(:exgithub, :secret_token),
        Poison.encode!(request)
      )

    conn =
      conn(:post, "/v1/events", Poison.encode!(request))
      |> put_req_header("x-hub-signature", "sha1=#{hmac}")
      |> put_req_header("content-type", "application/json")
      |> ExGitHub.Endpoint.call(@opts)

    assert conn.state == :sent
    assert conn.status == 400
  end

  test "it returns 401 for an invalid http signature" do
    request = %{
      action: "opened",
      issue: %{
        id: 519_124_749,
        number: 30,
        labels: ["SUSE"]
      }
    }

    fake_request = %{
      action: "closed",
      issue: %{
        id: 519_124_749,
        number: 30,
        labels: ["SUSE"]
      }
    }

    hmac =
      ExGitHub.Helpers.generate_http_signature(
        Application.get_env(:exgithub, :secret_token),
        Poison.encode!(fake_request)
      )

    conn =
      conn(:post, "/v1/events", Poison.encode!(request))
      |> put_req_header("x-hub-signature", "sha1=#{hmac}")
      |> put_req_header("content-type", "application/json")
      |> ExGitHub.Endpoint.call(@opts)

    assert conn.state == :sent
    assert conn.status == 401
  end

  test "it returns 401 when http signature header is not set" do
    request = %{
      action: "unknown",
      issue: %{
        id: 519_124_749,
        number: 30,
        labels: ["SUSE"]
      }
    }

    hmac =
      ExGitHub.Helpers.generate_http_signature(
        Application.get_env(:exgithub, :secret_token),
        Poison.encode!(request)
      )

    conn =
      conn(:post, "/v1/events", Poison.encode!(request))
      |> put_req_header("content-type", "application/json")
      |> ExGitHub.Endpoint.call(@opts)

    assert conn.state == :sent
    assert conn.status == 401
  end
end
