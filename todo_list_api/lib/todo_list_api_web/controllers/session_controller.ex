defmodule TodoListApiWeb.SessionController do
  use TodoListApiWeb, :controller

  alias TodoListApi.Todos
  alias TodoListApi.Auth.Authenticator

  def new(conn, _params) do
    render(conn, "new.html")
  end

  def create(conn, %{"session" => %{"login" => login, "password" => password}}) do
    case Todos.authenticate_user(login, password) do
      {:ok, user} ->
        {:ok, jwt, _full_claims} = Authenticator.encode_and_sign(user)

        conn
        |> put_resp_header("authorization", "Bearer #{jwt}")
        |> render("logged_in.html", jwt: jwt, user: user)

      {:error, _reason} ->
        conn
        |> put_flash(:error, "Invalid credentials")
        |> render("new.html")
    end
  end
end
