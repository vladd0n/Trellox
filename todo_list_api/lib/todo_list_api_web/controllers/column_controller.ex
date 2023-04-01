defmodule TodoListApiWeb.ColumnController do
  use TodoListApiWeb, :controller

  alias TodoListApi.Todos
  alias TodoListApi.Todos.Column

  def index(conn, _params) do
    columns = Todos.list_columns()
    json(conn, %{data: Enum.map(columns, &column_to_json/1)})
  end

  def show(conn, %{"id" => id}) do
    case Todos.get_column(id) do
      {:ok, %Column{} = column} ->
        json(conn, %{data: column_to_json(column)})

      {:error, :not_found} ->
        conn
        |> put_status(:not_found)
        |> json(%{error: "Column not found"})
    end
  end

  def create(conn, %{"board_id" => board_id} = params) do
    with %{"column" => column_params} <- params,
         {:ok, %Column{} = column} <-
           Todos.create_column(String.to_integer(board_id), column_params) do
      conn
      |> put_status(:created)
      |> json(%{data: column_to_json(column)})
    else
      {:error, changeset} ->
        conn
        |> put_status(:unprocessable_entity)
        |> json(%{
          error: "Invalid data",
          details: Ecto.Changeset.traverse_errors(changeset, &translate_error/1)
        })

      _ ->
        conn
        |> put_status(:unprocessable_entity)
        |> json(%{error: "Invalid data"})
    end
  end

  def update(conn, %{"id" => id, "column" => column_params}) do
    case Todos.update_column(id, column_params) do
      {:ok, column} ->
        # could use _to_json from previous controller modules?
        json(conn, %{data: column_to_json(column)})

      {:error, :not_found} ->
        conn
        |> put_status(:not_found)
        |> json(%{error: "Column not found"})

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
    case Todos.delete_column(id) do
      {:ok, _column} ->
        conn
        |> put_status(:no_content)
        |> send_resp(204, "")

      {:error, :not_found} ->
        conn
        |> put_status(:not_found)
        |> json(%{error: "Column not found"})
    end
  end

  defp column_to_json(column) do
    %{
      id: column.id,
      name: column.name,
      background: column.background,
      board_id: column.board_id
    }
  end

  defp translate_error({msg, opts}) do
    Enum.reduce(opts, msg, fn {key, value}, acc ->
      String.replace(acc, "%{#{key}}", to_string(value))
    end)
  end
end
