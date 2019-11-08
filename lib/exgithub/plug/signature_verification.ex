defmodule ExGitHub.Plug.SignatureVerification do
  import Plug.Conn
  require Logger

  def init(options), do: options

  def call(conn, opts) do
    verify_signature(conn, opts)
  end

  defp verify_signature(conn, opts) do
    with {:ok, digest} <- get_signature_digest(conn, opts),
         {:ok, secret} <- get_secret(opts[:secret]),
         true <- valid_request?(digest, secret, conn) do
      Logger.info("signature validated with success")
      conn
    else
      nil ->
        Logger.error(fn -> "webhook secret is not set" end)
        halt(send_resp(conn, 401, "webhook secret is not set"))

      false ->
        Logger.error(fn -> "received webhook with invalid signature" end)
        halt(send_resp(conn, 401, "received webhook with invalid signature"))

      {:error, msg} ->
        Logger.error(msg)
        halt(send_resp(conn, 401, msg))

      _ ->
        halt(
          send_resp(
            conn,
            401,
            "something went wrong. I bet a finger that signature matches failed."
          )
        )
    end
  end

  defp get_signature_digest(conn, opts) do
    case get_req_header(conn, opts[:header]) do
      ["sha1=" <> digest] -> {:ok, digest}
      _ -> nil
    end
  end

  defp get_secret(secret) when not is_nil(secret), do: {:ok, secret}
  defp get_secret(nil), do: {:error, "secret not found"}

  defp valid_request?(digest, secret, conn) do
    Logger.debug(conn.assigns.raw_body)
    hmac = :crypto.hmac(:sha, secret, conn.assigns.raw_body) |> Base.encode16(case: :lower)
    Logger.debug("Comparing signatures: is " <> digest <> " equal to " <> hmac)
    Plug.Crypto.secure_compare(digest, hmac)
  end
end
