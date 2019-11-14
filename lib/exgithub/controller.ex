defmodule ExGitHub.Controller do
  @moduledoc """
  Implements the logic and Jira invocation through Gira library.
  """

  require Logger

  @base_url System.get_env("JIRA_BASE_URL")
  @authorization_token System.get_env("JIRA_AUTH_TOKEN")
  @label Application.get_env(:exgithub, :github_trigger_label)

  def labeled_flow(request) do
    Logger.info("github action is labeled")

    with true <- is_label_present?(request["issue"]["labels"], @label),
         true <- is_state_open?(request["issue"]["state"]),
         {:ok, jira_resp} <- search_on_jira(request["issue"]["number"]),
         false <- is_exist?(jira_resp.status) do
      parse = ExGitHub.Parser.parse_jira(request)
      Logger.info("creating a jira issue for GitHub issue number #{request["issue"]["number"]}")
      create(parse)
    else
      _ ->
        Logger.info("labeled issue does not match one or more rules and it will be ignored.")
        %{status: 202, payload: %{msg: "github issue failed rules"}}
    end
  end

  def unlabeled_flow(request) do
    Logger.info("github action is unlabeled")

    with false <- is_label_present?(request["issue"]["labels"], @label),
         {:ok, jira_resp} <- search_on_jira(request["issue"]["number"]),
         true <- is_exist?(jira_resp.status) do
      Logger.info("closing jira issue for GitHub issue number #{request["issue"]["number"]}")
      close(jira_resp)
    else
      _ ->
        Logger.info("labeled issue does not match one or more rules and it will be ignored.")
        %{status: 202, payload: %{msg: "github issue failed rules"}}
    end
  end

  # data is the github request
  defp create(github_req) do
    {:ok, client} = Gira.new(@base_url, @authorization_token)
    {_, response} = Gira.create_issue_with_basic_info(client, github_req)
    response
  end

  defp close(jira_resp) do
    jira_id = Enum.at(jira_resp.payload["issues"], 0)["id"]
    {:ok, client} = Gira.new(@base_url, @authorization_token)
    {:ok, response} = Gira.close_issue(client, %{jira_id: jira_id, transition_id: "31"})
    response
  end

  defp search_on_jira(github_id) do
    {:ok, client} = Gira.new(@base_url, @authorization_token)
    filter = "labels%3DGitHub-#{github_id}"
    Logger.debug("check if github id #{github_id} exists in jira using filter #{filter}")

    Gira.get_issue_basic_info_by_query(client, filter)
  end

  # defp is_exist?(200), do: true
  defp is_exist?(status), do: status == 200
  defp is_exist?(nil), do: false

  defp is_state_open?(_state = "open"), do: true
  defp is_state_open?(_), do: false

  defp is_label_present?(labels, label_to_find) when not is_nil(labels),
    do: Enum.member?(labels, label_to_find)

  # defp is_label_present?(labels, label_to_find) when is_nil(labels), do: false
end
