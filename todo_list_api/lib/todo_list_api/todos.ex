defmodule TodoListApi.Todos do
  @moduledoc """
  The Todos context.
  """

  import Ecto.Query, warn: false
  alias TodoListApi.Repo

  alias TodoListApi.Todos.Task
  alias TodoListApi.Todos.Board
  alias TodoListApi.Todos.Column
  alias TodoListApi.Todos.User

  # Lists all tasks.
  def list_tasks do
    Repo.all(Task)
  end

  # Queries the database for a task by its ID and returns a %Task{} struct or raises an error if not found.
  def get_task!(id) do
    Repo.get!(Task, id)
  end

  # Retrieves a task by its ID.
  def get_task(id) do
    case Repo.get(Task, id) do
      nil -> {:error, :not_found}
      task -> {:ok, task}
    end
  end

  def create_task(column_id, task_params, default_flag \\ :none) do
    with {:ok, column} <- find_column_by_id_or_default_flag(column_id, default_flag),
         {:ok, %Task{} = task} <-
           Task.changeset(%Task{}, Map.put(task_params, "column_id", column.id)) |> Repo.insert() do
      {:ok, task}
    else
      {:error, %Ecto.Changeset{} = changeset} -> {:error, changeset}
      # Add this line
      {:error, :not_found} -> {:error, :not_found}
    end
  end

  defp find_column_by_id_or_default_flag(column_id, :none), do: get_column(column_id)

  defp find_column_by_id_or_default_flag(_column_id, default_flag),
    do: get_column_by_default_flag(default_flag)

  # find column with default flag
  def get_column_by_default_flag(default_flag) do
    Column
    |> where([c], c.default_flag == ^default_flag)
    |> Repo.one()
    |> case do
      nil -> {:error, :not_found}
      column -> {:ok, column}
    end
  end

  # Takes a task ID and a map of attributes, retrieves the task from the database,
  # creates a changeset with the new attributes, and updates the task in the database,
  # returning a tuple with :ok and the %Task{} struct or :error and the changeset with validation errors.
  def update_task(id, attrs) do
    case get_task(id) do
      {:ok, %Task{} = task} ->
        task
        |> Task.changeset(attrs)
        |> Repo.update()

      {:error, :not_found} ->
        {:error, :not_found}
    end
  end

  def delete_task(id) do
    case get_task(id) do
      {:ok, %Task{} = task} ->
        Repo.delete(task)
        {:ok, task}

      {:error, _} ->
        {:error, :not_found}
    end
  end

  def change_task(%Task{} = task, attrs \\ %{}) do
    Task.changeset(task, attrs)
  end

  # to retrieve only completed tasks
  def list_completed_tasks do
    from(t in Task, where: t.completed == true)
    |> Repo.all()
  end

  def get_tasks_by_column_id(column_id) do
    from(t in Task, where: t.column_id == ^column_id)
    |> Repo.all()
  end

  def move_task(id, column_id) do
    # get task by its ID
    case get_task(id) do
      {:ok, %Task{} = task} ->
        # update task with new 'column_id'
        Task.changeset(task, %{column_id: column_id})
        # update task in db
        |> Repo.update()

      {:error, _} ->
        {:error, :not_found}
    end
  end

  def clone_task(id) do
    case get_task(id) do
      {:ok, %Task{} = task} ->
        # create same task with other id
        # create new task struct and pipe it into Task.changeset/2
        %Task{}
        # create a map of the original task's attrs
        |> Task.changeset(
          Map.from_struct(task)
          # remove ':id'
          |> Map.drop([:id])
        )
        # insert the cloned task into db
        |> Repo.insert()

      {:error, _} ->
        {:error, :not_found}
    end
  end

  # Board functions

  def list_boards do
    Repo.all(Board)
  end

  # Update the list_boards function to take a user parameter
  def list_boards(user) do
    Board
    # Filter boards based on the user's id
    |> where(user_id: ^user.id)
    |> Repo.all()
  end

  def get_board(id) do
    case Repo.get(Board, id) do
      nil -> {:error, :not_found}
      board -> {:ok, board}
    end
  end

  # preload the columns association
  def get_board!(id), do: Board |> Repo.get!(id) |> Repo.preload(:columns)

  def create_board(attrs \\ %{}) do
    %Board{}
    |> Board.changeset(attrs)
    |> Repo.insert()
    |> case do
      {:ok, board} ->
        # preload the columns association
        board = Repo.preload(board, :columns)
        {:ok, board}

      error ->
        error
    end
  end

  def update_board(id, attrs) do
    case get_board(id) do
      {:ok, %Board{} = board} ->
        board
        |> Board.changeset(attrs)
        |> Repo.update()

      {:error, :not_found} ->
        {:error, :not_found}
    end
  end

  def delete_board(id) do
    case get_board(id) do
      {:ok, %Board{} = board} ->
        Repo.delete(board)
        {:ok, board}

      {:error, _} ->
        {:error, :not_found}
    end
  end

  # Column functions

  def list_columns do
    Repo.all(Column)
  end

  def get_column(id) do
    case Repo.get(Column, id) do
      nil -> {:error, :not_found}
      column -> {:ok, column}
    end
  end

  def create_column(board_id, attrs \\ %{}) do
    # set pos automatically based on the number of columns in the board
    position = next_position(board_id)

    %Column{}
    |> Column.changeset(Map.put(attrs, "board_id", board_id) |> Map.put("position", position))
    |> Repo.insert()
  end

  def update_column(id, attrs) do
    case get_column(id) do
      {:ok, %Column{} = column} ->
        column
        |> Column.changeset(attrs)
        |> Repo.update()

      {:error, :not_found} ->
        {:error, :not_found}
    end
  end

  def delete_column(id) do
    case get_column(id) do
      {:ok, %Column{} = column} ->
        Repo.delete(column)
        {:ok, column}

      {:error, _} ->
        {:error, :not_found}
    end
  end

  # find next available position for new column
  def next_position(board_id) do
    from(c in Column, where: c.board_id == ^board_id)
    |> Repo.aggregate(:max, :position)
    |> case do
      nil -> 1
      max_position -> max_position + 1
    end
  end

  # User functions

  def create_user(attrs \\ %{}) do
    %User{}
    |> User.changeset(attrs)
    |> Repo.insert()
  end

  # Get user by its ID
  def get_user(id) do
    case Repo.get(User, id) do
      nil -> {:error, :not_found}
      user -> {:ok, user}
    end
  end

  def get_user!(id), do: Repo.get!(User, id)

  def list_users, do: Repo.all(User)

  # Update user by its ID and a map of attributes
  def update_user(id, attrs) do
    case get_user(id) do
      {:ok, %User{} = user} ->
        user
        |> User.changeset(attrs)
        |> Repo.update()

      {:error, :not_found} ->
        {:error, :not_found}
    end
  end

  # Delete user by its ID
  def delete_user(id) do
    case get_user(id) do
      {:ok, %User{} = user} ->
        Repo.delete(user)
        {:ok, user}

      {:error, _} ->
        {:error, :not_found}
    end
  end

  def authenticate_user(login, password) do
    user = Repo.get_by(User, login: login)

    case user do
      nil ->
        {:error, :not_found}

      user ->
        if Bcrypt.check_pass(password, user.password_hash) do
          {:ok, user}
        else
          {:error, :invalid_credentials}
        end
    end
  end
end
