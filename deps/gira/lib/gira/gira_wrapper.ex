defmodule Gira.GiraWrapper do
  @moduledoc """
  This module provides a Jira client wrapper by leveraging on HTTPoison.Base 
  """
  use HTTPoison.Base

  @endpoint ""

  def process_url(url) do
    @endpoint <> url
  end

  def process_request_body(body) do
    body
    |> Jason.encode!()
  end

  @doc """
  Called before returning response body back the caller.

  ## Parameters
      - %HTTPoison.Response: HTTPoison response type
  """
  def process_response(%HTTPoison.Response{status_code: status_code, body: body})
      when status_code in [200, 201, 500] do
    body
    |> parse_body
    |> handle_response
  end

    @doc """
  Called before returning response back the caller.

  ## Parameters
      - %HTTPoison.Response: HTTPoison response type
  """
  def process_response(%HTTPoison.Response{status_code: status_code})
      when status_code in [204] do
      handle_response({ :ok, nil })
  end


  @doc """
  Called before returning response body back the caller.

  ## Parameters
      - %HTTPoison.Error
  """
  def process_response(%HTTPoison.Error{reason: {_, reason}}), do: {:error, reason}

  defp parse_body(body) do
    case Jason.decode(body) do
      {:ok, decoded} -> {:ok, decoded}
      {:error, error} -> {:error, error}
    end
  end

  defp handle_response({:error, error}) do
    %{status: 500, payload: error}
  end

  defp handle_response({:ok, %{"total" => 0}}) do
    %{status: 404, payload: nil}
  end

  defp handle_response({:ok, body}) do
    %{status: 200, payload: body}
  end
end
