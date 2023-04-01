defmodule TodoListApiWeb.UserController do
  use TodoListApiWeb, :controller

  alias TodoListApi.Todos

  def create(conn, %{"user" => user_params}) do
    case Todos.create_user(user_params) do
      {:ok, user} ->
        conn
        |> put_status(:created)
        |> json(%{data: user_to_json(user)})

      {:error, changeset} ->
        conn
        |> put_status(:unprocessable_entity)
        |> json(%{
          error: "Invalid data",
          details: Ecto.Changeset.traverse_errors(changeset, &translate_error/1)
        })
    end
  end

  def show(conn, %{"id" => id}) do
    case Todos.get_user(id) do
      {:ok, user} ->
        conn
        |> json(%{data: user_to_json(user)})

      {:error, :not_found} ->
        conn
        |> put_status(:not_found)
        |> json(%{error: "User not found"})
    end
  end

  def update(conn, %{"id" => id, "user" => user_params}) do
    case Todos.update_user(id, user_params) do
      {:ok, user} ->
        conn
        |> json(%{data: user_to_json(user)})

      {:error, :not_found} ->
        conn
        |> put_status(:not_found)
        |> json(%{error: "User not found"})

      {:error, changeset} ->
        conn
        |> put_status(:unprocessable_entity)
        |> json(%{
          error: "Invalid data",
          details: Ecto.Changeset.traverse_errors(changeset, &translate_error/1)
        })
    end
  end

  def delete(conn, %{"id" => id}) do
    case Todos.delete_user(id) do
      {:ok, user} ->
        conn
        |> json(%{data: user_to_json(user)})

      {:error, :not_found} ->
        conn
        |> put_status(:not_found)
        |> json(%{error: "User not found"})
    end
  end

  defp user_to_json(user) do
    %{
      id: user.id,
      login: user.login,
      nick: user.nick,
      email: user.email,
      title: user.title,
      company: user.company
    }
  end

  defp translate_error({msg, opts}) do
    Enum.reduce(opts, msg, fn {key, value}, acc ->
      String.replace(acc, "%{#{key}}", to_string(value))
    end)
  end

  def index(conn, _params) do
    users = Todos.list_users()

    conn
    |> json(%{data: Enum.map(users, &user_to_json/1)})
  end

  def login(conn, %{"user" => %{"login" => login, "password" => password}}) do
    case Todos.authenticate_user(login, password) do
      {:ok, user} ->
        {:ok, jwt, _claims} = Guardian.encode_and_sign(user, :access)

        conn
        |> put_status(:ok)
        |> json(%{token: jwt})

      {:error, :invalid_credentials} ->
        conn
        |> put_status(:unauthorized)
        |> json(%{error: "Invalid credentials"})

      {:error, :not_found} ->
        conn
        |> put_status(:not_found)
        |> json(%{error: "User not found"})
    end
  end

  # Add the logout/2 function
  def logout(conn, _params) do
    case Guardian.Plug.current_resource(conn) do
      nil ->
        conn
        |> put_status(:unprocessable_entity)
        |> json(%{error: "No user authenticated"})

      user ->
        {:ok, _claims} = Guardian.revoke(user, :access)

        conn
        |> put_status(:ok)
        |> json(%{message: "Logged out successfully"})
    end
  end
end
