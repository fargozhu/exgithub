defmodule ExGitHub.Model.Jira.Project do
  @derive Jason.Encoder
  defstruct key: "CAP"
end

defmodule ExGitHub.Model.Jira.CustomField17101 do
  @derive Jason.Encoder
  defstruct name: "none"
end

defmodule ExGitHub.Model.Jira.IssueType do
  @derive Jason.Encoder
  # User Story ID
  defstruct id: "10"
end

defmodule ExGitHub.Model.Jira.Reporter do
  @derive Jason.Encoder
  defstruct name: nil
end

defmodule ExGitHub.Model.Jira.Fields do
  @derive Jason.Encoder
  defstruct project: %ExGitHub.Model.Jira.Project{},
            custom_field_17101: %ExGitHub.Model.Jira.CustomField17101{},
            summary: nil,
            description: nil,
            issuetype: %ExGitHub.Model.Jira.IssueType{},
            reporter: %ExGitHub.Model.Jira.Reporter{},
            labels: nil
end

defmodule ExGitHub.Model.Jira do
  @derive Jason.Encoder
  defstruct fields: %ExGitHub.Model.Jira.Fields{}
end
