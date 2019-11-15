defmodule ExGitHub.Controller do
  require Logger
  require ExGitHub.GiraApi, as: GiraApi

  @label Application.get_env(:exgithub, :github_trigger_label)

  def labeled_flow(request) do
    Logger.info("github action is labeled")

    with true <- is_label_present?(request["issue"]["labels"], @label),
         true <- is_state_open?(request["issue"]["state"]),
         jira_resp <- search_jira_issue(request["issue"]["number"]),
         false <- is_exist?(jira_resp.status) do
      parse = ExGitHub.Parser.parse_jira(request)
      Logger.info("creating a jira issue for GitHub issue number #{request["issue"]["number"]}")
      create_jira_issue(parse)
    else
      _ ->
        Logger.info("labeled issue does not match one or more rules and it will be ignored.")
        %{status: 202, payload: %{msg: "github issue failed rules"}}
    end
  end

  def unlabeled_flow(request) do
    Logger.info("github action is unlabeled")

    with false <- is_label_present?(request["issue"]["labels"], @label),
         jira_resp <- search_jira_issue(request["issue"]["number"]),
         true <- is_exist?(jira_resp.status) do
      Logger.info("closing jira issue for GitHub issue number #{request["issue"]["number"]}")
      close_jira_issue(jira_resp)
    else
      _ ->
        Logger.info("labeled issue does not match one or more rules and it will be ignored.")
        %{status: 202, payload: %{msg: "github issue failed rules"}}
    end
  end

  # data is the github request
  defp create_jira_issue(github_req) do
    GiraApi.create(github_req)
  end

  defp close_jira_issue(jira_resp) do
    jira_id = Enum.at(jira_resp.payload["issues"], 0)["id"]
    GiraApi.close(jira_id)
  end

  defp search_jira_issue(github_id) do
    filter = "labels%3DGitHub-#{github_id}"
    Logger.debug("check if github id #{github_id} exists in jira using filter #{filter}")
    GiraApi.get(filter)
  end

  defp is_exist?(status), do: status == 200

  defp is_state_open?(_state = "open"), do: true
  defp is_state_open?(_), do: false

  defp is_label_present?(labels, label_to_find) when not is_nil(labels),
    do: Enum.member?(labels, label_to_find)

  # defp is_label_present?(labels, label_to_find) when is_nil(labels), do: false
end
