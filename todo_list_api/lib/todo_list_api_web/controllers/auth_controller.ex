defmodule TodoListApiWeb.AuthController do
  use TodoListApiWeb, :controller
  alias TodoListApi.Todos
  alias TodoListApi.Guardian

  def login(conn, %{"login" => login, "password" => password}) do
    case Todos.authenticate_user(login, password) do
      {:ok, user} ->
        {:ok, auth_token, _claims} = Guardian.encode_and_sign(user, :token)

        conn
        |> put_resp_header("authorization", "Bearer #{auth_token}")
        |> json(%{user: user, token: auth_token})

      {:error, _reason} ->
        conn
        |> put_status(:unauthorized)
        |> json(%{error: "Invalid credentials"})
    end
  end

  def logout(conn, _params) do
    conn
    |> Guardian.Plug.sign_out()
    |> json(%{message: "Logged out successfully"})
  end
end
