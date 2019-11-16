defmodule ExGitHub.Services.GiraServiceProvider do
  @callback create(%{}) :: %{}
  @callback close(integer()) :: %{}
  @callback get(String.t()) :: %{}
end
