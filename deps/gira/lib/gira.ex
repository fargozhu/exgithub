defmodule Gira do
  @moduledoc """
  This module defines the Gira contract/interface for clients to use.
  """
  @enforce_keys [:base_url, :authorization_token]
  defstruct(
    base_url: nil,
    authorization_token: nil
  )

  @type t() :: %__MODULE__{
          base_url: String.t(),
          authorization_token: String.t()
        }

  @doc """
  initialization of Gira by setting the necessary properties to a successful connection.

  ## Parameters
    
    - base_url: Jira server url to connect
    - auth_token: authorization token to be set at the HTTP header

     
  ## Examples

    iex> Gira.new("https://myserver.jira.com/rest/api/2", "Basic ajUHHJ9898hdhdsdsd434jh==")
    {:ok, %Gira{ authorization_token: "Basic ajUHHJ9898hdhdsdsd434jh==", base_url: "https://myserver.jira.com/rest/api/2" }}
  """
  @spec new(String.t(), String.t()) :: {atom(), %Gira{}}
  def new(base_url, auth_token) do
    {:ok,
     %Gira{
       base_url: base_url,
       authorization_token: auth_token
     }}
  end

  @doc """
  returns basic information of an existent Jira issue when running with a jql query

  ## Parameters
    - client: a client information that would support the establishment of a HTTP connection
    - filter: jql query

  ## Examples:
    - Gira.get_issue_basic_info_by_query(client, "labels%3DGithub-1210")
    { :ok, %{ status: 200, payload: % {} }}
  """
  @spec get_issue_basic_info_by_query(%{}, String.t()) :: {atom(), %{ status: number, payload: %{}}}
  def get_issue_basic_info_by_query(client, filter) do
    Gira.GiraWrapper.get(
      get_base_url(client) <> "/search" <> "?jql=" <> filter <> "&fields=total",
      [{"Authorization", get_authorization_token(client)}, {"Content-type", "application/json"}]
    )
  end

  @doc """

  """
  @spec create_issue_with_basic_info(%{}, %{}) :: {atom(), %{ status: number, payload: %{}}}
  def create_issue_with_basic_info(client, payload) do
    Gira.GiraWrapper.post(
      get_base_url(client) <> "/issue",
      payload,
      [{"Authorization", get_authorization_token(client)}, {"Content-type", "application/json"}]
    )
  end

  @doc """
  
  """
  @spec close_issue(String.t(), %{ jira_id: String.t(), transition_id: String.t() }) :: {atom(), %{ status: number, payload: %{}}}
  def close_issue(client, %{jira_id: jira_id, transition_id: trans_id}) do
    Gira.GiraWrapper.post(
      get_base_url(client) <> "/issue/" <> jira_id <> "/transitions",
      %{ transition: trans_id },
      [{"Authorization", get_authorization_token(client)}, {"Content-type", "application/json"}]
    )  
  end

  defp get_base_url(client), do: client.base_url
  defp get_authorization_token(client), do: client.authorization_token
end
