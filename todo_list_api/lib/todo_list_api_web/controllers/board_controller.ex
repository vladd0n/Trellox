defmodule TodoListApiWeb.BoardController do
  use TodoListApiWeb, :controller
  alias TodoListApi.Guardian

  alias TodoListApi.Todos
  alias TodoListApi.Todos.Board

  # lists all the boards -> JSON
  def index(conn, _params) do
    boards = Todos.list_boards()
    json(conn, %{data: Enum.map(boards, &board_to_json/1)})
  end

  # fetches a board by ID and returns as JSON or error
  def show(conn, %{"id" => id}) do
    case Todos.get_board(id) do
      {:ok, %Board{} = board} ->
        json(conn, %{data: board_to_json(board)})

      {:error, :not_found} ->
        conn
        |> put_status(:not_found)
        |> json(%{error: "Board not found"})
    end
  end

  def create(conn, %{"name" => name, "background" => background, "columns_count" => columns_count}) do
    with {:ok, %Board{} = board} <-
           Todos.create_board(%{
             "name" => name,
             "background" => background,
             "columns_count" => columns_count
           }) do
      conn
      |> put_status(:created)
      |> json(%{data: board_to_json(board)})
    end
  end

  # update with provided params
  def update(conn, %{"id" => id, "board" => board_params}) do
    case Todos.update_board(String.to_integer(id), board_params) do
      {:ok, board} ->
        json(conn, %{data: board_to_json(board)})

      {:error, :not_found} ->
        conn
        |> put_status(:not_found)
        |> json(%{error: "Board not found"})

      {:error, changeset} ->
        conn
        |> put_status(:unprocessable_entity)
        |> json(%{
          error: "Invalid data",
          details: Ecto.Changeset.traverse_errors(changeset, &translate_error/1)
        })
    end
  end

  # delete or 204 status
  def delete(conn, %{"id" => id}) do
    case Todos.delete_board(id) do
      {:ok, _board} ->
        conn
        |> put_status(:no_content)
        |> send_resp(204, "")

      {:error, :not_found} ->
        conn
        |> put_status(:not_found)
        |> json(%{error: "Board not found"})
    end
  end

  defp board_to_json(board) do
    %{
      id: board.id,
      name: board.name,
      background: board.background
    }
  end

  defp translate_error({msg, opts}) do
    Enum.reduce(opts, msg, fn {key, value}, acc ->
      String.replace(acc, "%{#{key}}", to_string(value))
    end)
  end
end
