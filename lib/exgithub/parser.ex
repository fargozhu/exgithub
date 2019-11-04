defmodule ExGitHub.Parser do

    @doc """
    Parse event record from the API response json.
    """
    def parse_event(object) do
        event = struct(ExGitHub.Model.Event, object)
        issue = parse_issue(event.issue)
        %{ event | issue: issue }
    end

    @doc """
    Parse issue record from the API response json.
    """
    def parse_issue(object) do
        struct(ExGitHub.Model.Issue, object)
    end

    @doc """
    Parse user record from the API response json.
    """
    def parse_user() do
        struct(ExGitHub.Model.User, object)
    end
end