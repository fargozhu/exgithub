defmodule ExGitHub.Controller do    
    @moduledoc """
    Implements the logic and Jira invocation through Gira library.
    """
    use ExGitHub.Github

    @doc """
    implements the creation logic (action = opened) by parsing the Github payload
    and invoking the Gira library with the needed information.
    """
    @spec create() :: number
    def create(%{}) do
        
    end

    @doc """
    implements the closing logic (action = closed) by parsing the Github payload
    and invoking the Gira library with the needed information.
    """
    @spec close() :: number

    @doc """
    implements the comment adding logic (action = created) by parsing the Github payload
    and invoking the Gira library with the needed information.
    """
    @spec add_comment() :: number
end