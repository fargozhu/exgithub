defmodule ExGitHub.Test.Controller do
  use ExUnit.Case, async: true

  @label "SUSE"
  describe "labeled flows" do
    test "it creates a jira issue with success" do
      resp = labeled_flow(request, @label, ExGitHub.Test.Services.GiraServiceMock)
      assert true == false
    end

    test "it fails creating a jira issue due lack of trigger labels" do
      assert true == false
    end

    test "it fails creating a jira issue because github issue is not in open state" do
      assert true == false
    end

    test "it fails creating a jira issue because already exists in jira" do
      assert true == false
    end
  end

  describe "unlabeled flows" do
    test "it closes a jira issue with success" do
      assert true == false
    end

    test "it fails closing jira issue because trigger label is present" do
      assert true == false
    end

    test "it fails creating a jira issue because it does not exist in jira" do
      assert true == false
    end
  end
end
