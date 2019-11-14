defmodule ExGitHub.Controller do
  @moduledoc """
  Implements the logic and Jira invocation through Gira library.
  """

  require Logger

  @base_url System.get_env("JIRA_BASE_URL")
  @authorization_token System.get_env("JIRA_AUTH_TOKEN")
  @label Application.get_env(:exgithub, :github_trigger_label)

  def labeled_flow(request) do
    with true <- is_label_present?(request["issue"]["labels"], @label),
         true <- is_state_open?(request["issue"]["state"]),
         {:ok, jira_resp} <- search_on_jira(request["issue"]["number"]),
         false <- is_exist?(jira_resp.status) do
      # jira_id = Enum.at(jira_resp.payload["issues"], 0)["id"]
      Logger.info("creating a jira issue for GitHub issue number #{request["issue"]["number"]}")
      parse = ExGitHub.Parser.parse_jira(request)
      create(parse)
    else
      _ ->
        Logger.info("labeled issue does not match any the rules and it will be ignored.")
        %{status: 202, payload: "ignored"}
    end
  end

  def create(data) do
    {:ok, client} = Gira.new(@base_url, @authorization_token)
    {_, response} = Gira.create_issue_with_basic_info(client, data)
    response
  end

  def close(data) do
    {:ok, client} = Gira.new(@base_url, @authorization_token)
    {:ok, response} = Gira.close_issue(client, %{jira_id: data.jira_id, transition_id: "31"})
    response
  end

  defp search_on_jira(github_id) do
    {:ok, client} = Gira.new(@base_url, @authorization_token)
    filter = "labels%3DGitHub-#{github_id}"
    Logger.debug("check if github id #{github_id} exists in jira using filter #{filter}")
    Gira.get_issue_basic_info_by_query(client, filter)
  end

  defp is_exist?(status) when not is_nil(status), do: status == 200
  defp is_exist?(nil), do: false

  defp is_state_open?(_state = "open"), do: true
  defp is_state_open?(_), do: false

  defp is_label_present?(labels, label_to_find) when not is_nil(labels),
    do: Enum.member?(labels, label_to_find)

  # defp is_label_present?(labels, label_to_find) when is_nil(labels), do: false
end
