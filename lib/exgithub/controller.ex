defmodule ExGitHub.Controller do
  @moduledoc """
  Implements the logic and Jira invocation through Gira library.
  """

  require Logger

  @base_url System.get_env("JIRA_BASE_URL")
  @authorization_token System.get_env("JIRA_AUTH_TOKEN")

  def create(request) do
    Logger.info("start creating a jira issue...")
    {:ok, client} = Gira.new(@base_url, @authorization_token)

    with {:ok, jira_resp} <- search_github_on_jira(client, request["issue"]["number"]),
         false <- is_exist?(jira_resp.status),
         parse = ExGitHub.Parser.parse_jira(request),
         {:ok, _response} = Gira.create_issue_with_basic_info(client, parse) do
      Logger.info("jira issue will be created")
      %{status: 200, payload: %{msg: "github issue created in jira"}}
    else
      true ->
        Logger.debug("github issue already linked")
        %{status: 200, payload: %{msg: "github issue already exists in jira"}}

      {:error, response} ->
        Logger.error("something happen while creating a jira issue")
        IO.inspect(response)

        %{
          status: 500,
          payload: %{
            msg: "something happen while creating a jira issue. check the logs for more info"
          }
        }
    end
  end

  @spec close(any) :: none
  def close(request) do
    {:ok, client} = Gira.new(@base_url, @authorization_token)

    with {:ok, jira_resp} <- search_github_on_jira(client, request["issue"]["number"]),
         true <- is_exist?(jira_resp.status),
         jira_id = Enum.at(jira_resp.payload["issues"], 0)["id"] do
      Logger.debug("jira issue with id #{jira_id} will be closed")

      {_status, response} = Gira.close_issue(client, %{jira_id: jira_id, transition_id: "31"})
      response
    else
      true -> %{status: 200, payload: %{msg: "github issue already exists in jira"}}
      false -> %{status: 404, payload: %{msg: "github issue not found"}}
    end
  end

  @spec search_github_on_jira({:atom, %Gira{}}, String.t()) :: %Elixir.Gira{}
  defp search_github_on_jira(client, github_id) do
    filter = "labels%3DGitHub-#{github_id}"

    Logger.debug("check if github id #{github_id} exists in jira using filter #{filter}")

    Gira.get_issue_basic_info_by_query(client, filter)
  end

  @spec is_exist?(number) :: boolean()
  defp is_exist?(status) when not is_nil(status), do: status == 200
  defp is_exist?(nil), do: false
end
