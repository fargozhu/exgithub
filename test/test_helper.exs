ExUnit.start()

defmodule ExGitHub.Helpers do
  def generate_http_signature(secret, payload) do
    :crypto.hmac(:sha, secret, payload) |> Base.encode16(case: :lower)
  end
end
