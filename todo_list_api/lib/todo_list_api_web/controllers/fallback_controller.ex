defmodule TodoListApiWeb.FallbackController do
  use TodoListApiWeb, :controller

  def call(conn, {:error, :not_found}) do
    conn
    |> put_status(:not_found)
    |> put_view(TodoListApiWeb.ErrorView)
    |> render(:"404")
  end

  def call(conn, {:error, %Ecto.Changeset{} = changeset}) do
    conn
    |> put_status(:unprocessable_entity)
    |> put_view(TodoListApiWeb.ChangesetView)
    |> render(:error, changeset: changeset)
  end
end
