defmodule ExGitHub.Controller do
  require Logger

  @label Application.get_env(:exgithub, :github_trigger_label)

  def labeled_flow(request, service_module \\ ExGitHub.Services.GiraService) do
    Logger.info("github action is labeled")

    with true <- is_label_present?(request["issue"]["labels"], @label),
         true <- is_state_open?(request["issue"]["state"]),
         jira_resp <- search_jira_issue(request["issue"]["number"], service_module),
         false <- is_exist?(jira_resp.status) do
      parse = ExGitHub.Parser.parse_jira(request)
      Logger.info("creating a jira issue for GitHub issue number #{request["issue"]["number"]}")
      create_jira_issue(parse, service_module)
    else
      _ ->
        Logger.info("labeled issue does not match one or more rules and it will be ignored.")
        %{status: 202, payload: %{msg: "github issue failed rules"}}
    end
  end

  def unlabeled_flow(request, service_module \\ ExGitHub.Services.GiraService) do
    Logger.info("github action is unlabeled")

    with false <- is_label_present?(request["issue"]["labels"], @label),
         jira_resp <- search_jira_issue(request["issue"]["number"], service_module),
         true <- is_exist?(jira_resp.status) do
      Logger.info("closing jira issue for GitHub issue number #{request["issue"]["number"]}")
      close_jira_issue(jira_resp, service_module)
    else
      _ ->
        Logger.info("labeled issue does not match one or more rules and it will be ignored.")
        %{status: 202, payload: %{msg: "github issue failed rules"}}
    end
  end

  # creates a new jira issue
  defp create_jira_issue(github_req, service_module \\ ExGitHub.Services.GiraService) do
    service_module.create(github_req)
  end

  # closes an existent jira issue
  defp close_jira_issue(jira_resp, service_module \\ ExGitHub.Services.GiraService) do
    jira_id = Enum.at(jira_resp.payload["issues"], 0)["id"]
    service_module.close(jira_id)
  end

  # search a jira issue based on GitHub-xxx label
  defp search_jira_issue(github_id, service_module \\ ExGitHub.Services.GiraService) do
    filter = "labels%3DGitHub-#{github_id}"
    Logger.debug("check if github id #{github_id} exists in jira using filter #{filter}")
    service_module.get(filter)
  end

  defp is_exist?(status), do: status == 200

  defp is_state_open?(_state = "open"), do: true
  defp is_state_open?(_), do: false

  defp is_label_present?(labels, label_to_find) when not is_nil(labels),
    do: Enum.member?(labels, label_to_find)

  # defp is_label_present?(labels, label_to_find) when is_nil(labels), do: false
end
