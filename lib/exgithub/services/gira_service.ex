defmodule ExGitHub.Services.GiraService do
  alias ExGitHub.Services.GiraServiceProvider

  require Logger

  @behaviour GiraServiceProvider

  @doc """
    Opens a new jira issue with customized information parsed from GitHub request

    Returns '%{}'

    ## Examples:

  """
  @impl GiraServiceProvider
  def create(req) do
    {:ok, client} = new()
    {_, response} = Gira.create_issue_with_basic_info(client, req)
    response
  end

  @doc """
  Closes an jira issue associated with a `jira_id`

  Returns '%{}'

  ## Examples:

  """
  @impl GiraServiceProvider
  def close(jira_id) do
    {:ok, client} = new()
    {:ok, response} = Gira.close_issue(client, %{jira_id: jira_id, transition_id: "31"})
    response
  end

  @doc """
  Searches for issues within a customized `filter`

  Returns '%{}'

  ## Examples:

  """
  @impl GiraServiceProvider
  def get(filter) do
    {:ok, client} = new()
    {_status, response} = Gira.get_issue_basic_info_by_query(client, filter)
    response
  end

  defp new() do
    base_url = Application.get_env(:exgithub, :jira_base_url)
    authorization_token = Application.get_env(:exgithub, :jira_auth_token)

    Logger.debug("initialize new client with URL: #{base_url}")

    Gira.new(base_url, authorization_token)
  end
end
