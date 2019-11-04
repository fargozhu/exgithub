defmodule ExGitHub.Model.Event do
    @moduledoc """

    ## Reference
    https://developer.github.com/webhooks/#events
    """
    defstruct action: nil, issue: nil, repository: nil, organization: nil, sender: nil
end

defmodule ExGitHub.Model.Issue do
    @moduledoc """

    ## Reference
    https://developer.github.com/webhooks/#events
    """
    defstruct id: nil, title: nil, user: nil, labels: nil, body: nil
end

defmodule ExGitHub.Model.User do
    @moduledoc """

    ## Reference
    https://developer.github.com/webhooks/#events
    """
    defstruct login: nil
end

