defmodule TodoListApiWeb.AuthErrorHandler do
  @moduledoc false
  import Plug.Conn

  def init(opts), do: opts

  def call(conn, _opts) do
    case Guardian.Plug.error_handler(conn) do
      {:ok, _claims} -> conn
      {:error, _reason} -> unauthenticated(conn, %{})
    end
  end

  def unauthenticated(conn, _params) do
    conn
    |> put_status(:unauthorized)
    |> put_resp_header("content-type", "application/json")
    |> send_resp(401, "{\"error\":\"Unauthorized\"}")
    |> halt()
  end

  def auth_error(conn, {type, _reason}, _opts) do
    case type do
      :unauthenticated -> unauthenticated(conn, %{})
      _ -> conn
    end
  end
end
