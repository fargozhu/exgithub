defmodule ExGitHub.Controller do
  @moduledoc """
  Implements the logic and Jira invocation through Gira library.
  """

  require Logger

  @base_url System.get_env("JIRA_BASE_URL")
  @authorization_token System.get_env("JIRA_AUTH_TOKEN")

  def create(request) do
    payload = ExGitHub.Parser.parse_jira(request)
    {:ok, client} = Gira.new(@base_url, @authorization_token)
    {status, response} = Gira.create_issue_with_basic_info(client, payload)
    response
  end
end
