defmodule ExGitHub.Test.Services.GiraServiceMock do
  alias ExGitHub.Services.GiraServiceProvider

  @behaviour GiraServiceProvider

  @doc """
    Opens a new jira issue with customized information parsed from GitHub request

    Returns '%{}'

    ## Examples:

  """
  @impl GiraServiceProvider
  def create(req) do
    {:ok, %{}}
  end

  @doc """
  Closes an jira issue associated with a `jira_id`

  Returns '%{}'

  ## Examples:

  """
  @impl GiraServiceProvider
  def close(jira_id) do
    {:ok, %{}}
  end

  @doc """
  Searches for issues within a customized `filter`

  Returns '%{}'

  ## Examples:

  """
  @impl GiraServiceProvider
  def get(filter) do
    {:ok, %{}}
  end
end
