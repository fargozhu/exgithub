defmodule Ninja.Jira do
    defstruct(
        issue_id: nil,
        issue_title: nil,
        issue_body: nil,
        issue_user: nil,
        repository_name: nil,
    )
    
    def new(event) do
        %Ninja.Jira{
            issue_id: event.issue.id,
            issue_title: event.issue.title,
            issue_body: event.issue.body,
            issue_user: event.issue.user.login,
            repository_name: event.repository.full_name,
        }
    end

    def process_jira_issue(issue, _event = %{ "action" => "opened" }) do
        IO.inspect issue
        { :ok, Enum.random(0..999999) }
    end

    def process_jira_issue(issue, _event = %{ "action" => "closed" }) do
        IO.inspect issue
        { :ok, Enum.random(0..999999) }
    end

    def process_jira_issue(issue, _event = %{ "action" => "created" }) do
        IO.inspect issue
        { :ok, Enum.random(0..999999) }
    end
end