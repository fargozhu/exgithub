defmodule ExGitHub.GiraServiceTest do
  use ExUnit.Case, async: true
  # require ExGitHub.GiraApi, as: GiraApi
  import Mox

  setup :verify_on_exit!

  test "it creates a gira issue with success" do
    req = %{
      fields: %{
        customfield_17101: %{name: "none"},
        description: "something describing whatever",
        issuetype: %{id: 10},
        labels: ["GitHub-799", "Butler"],
        project: %{key: "CAP"},
        reporter: %{name: "jaimegomes"},
        summary: "sadd"
      }
    }

    ExGitHub.Services.GiraServiceMock
    |> expect(:create, fn _ ->
      %{
        payload: %{
          "id" => "411705",
          "key" => "CAP-1024",
          "self" => "https://jira.suse.com/rest/api/2/issue/411705"
        },
        status: 200
      }
    end)

    res = ExGitHub.Services.GiraServiceMock.create(req)

    assert res.status == 200
  end
end
