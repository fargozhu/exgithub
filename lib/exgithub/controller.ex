defmodule ExGitHub.Controller do
  require Logger

  def labeled_flow(request, service_module \\ ExGitHub.Services.GiraService) do
    Logger.info("github action is...'labeled'")

    with true <- is_label_present?(request["issue"]["labels"]),
         true <- is_state_open?(request["issue"]["state"]),
         {:ok, %{status: 404, payload: _}} <-
           search_jira_issue(request["issue"]["number"], service_module) do
      parse = ExGitHub.Parser.parse_jira(request)
      create_jira_issue(parse, service_module)
    else
      {:error, %{status: 500, payload: payload}} ->
        Logger.error("something got wrong when calling jira service")
        {:error, %{status: 500, payload: payload}}

      _ ->
        Logger.info("labeled issue does not match one or more rules and it will be ignored.")
        {:ok, %{status: 202, payload: %{msg: "github issue failed rules"}}}
    end
  end

  def unlabeled_flow(request, service_module \\ ExGitHub.Services.GiraService) do
    Logger.info("github action is...'unlabeled'")

    with false <- is_label_present?(request["issue"]["labels"]),
         {:ok, %{status: 200, payload: payload}} <-
           search_jira_issue(request["issue"]["number"], service_module) do
      close_jira_issue(payload, service_module)
    else
      {:error, %{status: 500, payload: payload}} ->
        Logger.error("something got wrong when calling jira service")
        {:error, %{status: 500, payload: payload}}

      _ ->
        Logger.info("labeled issue does not match one or more rules and it will be ignored.")
        {:ok, %{status: 202, payload: %{msg: "github issue failed rules"}}}
    end
  end

  def closed_flow(request, service_module \\ ExGitHub.Services.GiraService) do
    Logger.info("github action is...'closed'")

    with {:ok, %{status: 200, payload: payload}} <-
           search_jira_issue(request["issue"]["number"], service_module) do
      close_jira_issue(payload, service_module)
    else
      {:error, %{status: 500, payload: payload}} ->
        Logger.error("something got wrong when calling jira service")
        {:error, %{status: 500, payload: payload}}

      _ ->
        Logger.info("closed issue does not match one or more rules and it will be ignored.")
        {:ok, %{status: 202, payload: %{msg: "github issue failed rules"}}}
    end
  end

  # creates a new jira issue
  defp create_jira_issue(github_req, service_module \\ ExGitHub.Services.GiraService) do
    service_module.create(github_req)
  end

  # closes an existent jira issue
  defp close_jira_issue(jira_resp, service_module \\ ExGitHub.Services.GiraService) do
    jira_id = Enum.at(jira_resp["issues"], 0)["id"]
    service_module.close(jira_id)
  end

  # search a jira issue based on GitHub-xxx label
  defp search_jira_issue(github_id, service_module \\ ExGitHub.Services.GiraService),
    do: service_module.get("labels%3DGitHub-#{github_id}")

  defp is_exist?(status), do: status == 200

  defp is_state_open?(_state = "open"), do: true
  defp is_state_open?(_), do: false

  defp is_label_present?(labels) when not is_nil(labels) do
    label = Application.get_env(:exgithub, :github_trigger_label)
    Enum.member?(labels, label)
  end

  defp print_me(msg) do
    IO.inspect(msg)
    true
  end
end
