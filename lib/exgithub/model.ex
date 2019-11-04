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

    @moduledoc """

    ## Reference
    https://developer.github.com/webhooks/#events
    """
defmodule ExGitHub.Model.User do
    defstruct login: nil
end

