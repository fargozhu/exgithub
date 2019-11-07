defmodule ExGitHub.Parser do
  @doc """
  Parse an GitHub event struct (JASON) into %ExGitHub.Model.Jira
  """
  def parse_jira(object) do
    %{
      fields: parse_jira_fields(object)
    }
  end

  def parse_jira_fields(object) do
    %{
      summary: parse_jira_summary(object["issue"]),
      description: parse_jira_description(object["issue"]),
      project: parse_jira_project(),
      issuetype: parse_jira_issuetype(),
      reporter: parse_jira_reporter(),
      customfield_17101: parse_jira_customfield17101(),
      labels: parse_jira_labels(object["issue"])
    }
  end

  def parse_jira_project() do
    %{key: "CAP"}
  end

  def parse_jira_summary(object) do
    object["title"]
  end

  def parse_jira_description(object) do
    object["body"] <> "\n\n" <> object["url"]
  end

  def parse_jira_labels(object) do
    ["GitHub-" <> to_string(object["number"]), "Butler"]
  end

  def parse_jira_issuetype() do
    %{id: 10}
  end

  def parse_jira_reporter() do
    # %{name: object["login"]}
    # hardcoded 'cause we do not have a Jira bot and the Github user may not be part of SUSE
    %{name: "jaimegomes"}
  end

  def parse_jira_customfield17101() do
    %{name: "none"}
  end
end
