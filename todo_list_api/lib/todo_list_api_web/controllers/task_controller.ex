defmodule TodoListApiWeb.TaskController do
  use TodoListApiWeb, :controller

  alias TodoListApi.Todos
  alias TodoListApi.Todos.Task

  # Actions added
  # Lists all tasks.
  def index(conn, _params) do
    # <- tasks = Todos.list_tasks()
    tasks = Todos.list_tasks()
    # render(conn, "index.json", tasks: tasks)
    json(conn, %{data: Enum.map(tasks, &task_to_json/1)})
  end

  def show(conn, %{"id" => id}) do
    case Todos.get_task(id) do
      {:ok, %Task{} = task} ->
        json(conn, %{data: task_to_json(task)})

      {:error, :not_found} ->
        conn
        |> put_status(:not_found)
        |> json(%{error: "Task not found"})
    end
  end

  def create(conn, %{
        "column_id" => column_id,
        "is_complete" => is_complete,
        "description" => description,
        "title" => title,
        "default_flag" => default_flag
      }) do
    task_params = %{"is_complete" => is_complete, "description" => description, "title" => title}

    case Todos.create_task(
           String.to_integer(column_id),
           task_params,
           String.to_atom(default_flag)
         ) do
      {:ok, %Task{} = task} ->
        conn
        |> put_status(:created)
        |> json(%{data: task_to_json(task)})

      # Update this pattern match
      {:error, %Ecto.Changeset{} = changeset} ->
        conn
        |> put_status(:unprocessable_entity)
        |> json(%{
          error: "Invalid data",
          details: Ecto.Changeset.traverse_errors(changeset, &translate_error/1)
        })

      # Add this clause
      {:error, :not_found} ->
        conn
        |> put_status(:not_found)
        |> json(%{error: "Column not found"})
    end
  end

  def update(conn, %{"id" => id, "task" => task_params}) do
    case Todos.update_task(String.to_integer(id), task_params) do
      {:ok, task} ->
        json(conn, %{data: task_to_json(task)})

      {:error, :not_found} ->
        conn
        |> put_status(:not_found)
        |> json(%{error: "Task not found"})

      {:error, changeset} ->
        conn
        |> put_status(:unprocessable_entity)
        # generate a more user-friendly error message
        |> json(%{
          error: "Invalid data",
          details: Ecto.Changeset.traverse_errors(changeset, &translate_error/1)
        })
    end
  end

  # convert the error messages into a more readable format (optional)
  defp translate_error({msg, opts}) do
    Enum.reduce(opts, msg, fn {key, value}, acc ->
      String.replace(acc, "%{#{key}}", to_string(value))
    end)
  end

  def delete(conn, %{"id" => id}) do
    case Todos.delete_task(id) do
      {:ok, _task} ->
        conn
        |> put_status(:no_content)
        |> send_resp(204, "")

      {:error, :not_found} ->
        conn
        |> put_status(:not_found)
        |> json(%{error: "Task not found"})
    end
  end

  # new 'move' acition
  def move(conn, %{"id" => id, "column_id" => column_id}) do
    # call from Todos
    case Todos.move_task(String.to_integer(id), String.to_integer(column_id)) do
      # succefully moved
      {:ok, task} ->
        json(conn, %{data: task_to_json(task)})

      # task not found
      {:error, :not_found} ->
        conn
        |> put_status(:not_found)
        |> json(%{error: "Task not found"})
    end
  end

  # new 'clone' action
  def clone(conn, %{"id" => id}) do
    case Todos.clone_task(String.to_integer(id)) do
      {:ok, %Task{} = task} ->
        json(conn, %{data: task_to_json(task)})

      {:error, :not_found} ->
        conn
        |> put_status(:not_found)
        |> json(%{error: "Task not found"})
    end
  end

  def tasks_by_column_id(conn, %{"column_id" => column_id}) do
    tasks = Todos.get_tasks_by_column_id(String.to_integer(column_id))
    json(conn, %{data: Enum.map(tasks, &task_to_json/1)})
  end

  def task_to_json(task) do
    %{
      id: task.id,
      title: task.title,
      # Add this line
      description: task.description,
      is_complete: task.is_complete,
      column_id: task.column_id,
      inserted_at: task.inserted_at,
      updated_at: task.updated_at
    }
  end
end
