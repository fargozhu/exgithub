defmodule ExGitHub.Services.GiraService do
  alias ExGitHub.Services.GiraServiceProvider

  require Logger

  @behaviour GiraServiceProvider

  @doc """
    Opens a new jira issue with customized information parsed from GitHub request
  """
  @impl GiraServiceProvider
  def create(req) do
    Logger.debug("creating new jira issue with request: #{inspect(req)}")

    new()
    |> Gira.create_issue_with_basic_info(req)
  end

  @doc """
  Closes an jira issue associated with a `jira_id`
  """
  @impl GiraServiceProvider
  def close(jira_id) do
    Logger.debug("closing jira issue with id: #{jira_id}")

    new()
    |> Gira.close_issue(%{jira_id: jira_id, transition_id: "31"})
  end

  @doc """
  Searches for issues within a customized `filter`
  """
  @impl GiraServiceProvider
  def get(filter) do
    Logger.debug("searching for jira issue with filter: #{filter}")

    new()
    |> Gira.get_issue_basic_info_by_query(filter)
  end

  defp new() do
    base_url = Application.get_env(:exgithub, :jira_base_url)
    authorization_token = Application.get_env(:exgithub, :jira_auth_token)
    Gira.new(base_url, authorization_token)
  end
end
