defmodule TodoListApiWeb.TaskControllerTest do
  use TodoListApiWeb.ConnCase

  alias TodoListApi.Todos

  setup do
    conn = build_conn()

    # Create a test user with the required fields
    {:ok, user} =
      Todos.create_user(%{
        login: "test@example.com",
        password: "password",
        nick: "Test User",
        email: "test@example.com"
      })

    {:ok, board} =
      Todos.create_board(%{"name" => "Board", "background" => "blue", "columns_count" => 2})

    {:ok, column} =
      Todos.create_column(board.id, %{
        "title" => "Sample column",
        "name" => "Sample column name",
        "background" => "blue"
      })

    {:ok, task} =
      Todos.create_task(Integer.to_string(column.id), %{
        "title" => "Sample task",
        "description" => "A sample task",
        "is_complete" => false
      })

    {:ok, _new_column} =
      Todos.create_column(board.id, %{
        "title" => "New column",
        "name" => "New column name",
        "background" => "green",
        "default_flag" => "true"
      })

    %{conn: conn, user: user, column_id: column.id, task_id: task.id}
  end

  describe "index" do
    test "lists all tasks", %{conn: conn, user: user} do
      conn = authenticate_request(conn, user)
      # hardcoded path
      conn = get(conn, "/api/tasks")
      assert json_response(conn, 200)["data"] |> length() > 0
    end
  end

  describe "show" do
    test "shows a single task", %{conn: conn, task_id: task_id, user: user} do
      conn = authenticate_request(conn, user)
      conn = get(conn, "/api/tasks/#{task_id}")
      assert json_response(conn, 200)["data"]["id"] == task_id
    end

    test "returns not found for a non-existent task", %{conn: conn, user: user} do
      conn = authenticate_request(conn, user)
      conn = get(conn, "/api/tasks/-1")
      assert json_response(conn, 404)["error"] == "Task not found"
    end
  end

  describe "create" do
    test "creates a task successfully", %{conn: conn, column_id: column_id, user: user} do
      conn = authenticate_request(conn, user)

      task_params = %{
        "column_id" => Integer.to_string(column_id),
        "is_complete" => false,
        "description" => "New task description",
        "title" => "New task",
        "default_flag" => "false"
      }

      conn = post(conn, "/api/tasks", task_params)
      assert json_response(conn, 201)["data"]["id"]
    end
  end

  describe "update" do
    test "updates a task successfully", %{conn: conn, task_id: task_id, user: user} do
      conn = authenticate_request(conn, user)
      update_params = %{"task" => %{"title" => "Updated task"}}
      conn = put(conn, "/api/tasks/#{task_id}", update_params)
      assert json_response(conn, 200)["data"]["title"] == "Updated task"
    end
  end

  describe "delete" do
    test "deletes a task successfully", %{conn: conn, task_id: task_id, user: user} do
      conn = authenticate_request(conn, user)
      conn = delete(conn, "/api/tasks/#{task_id}")
      assert response(conn, 204) == ""
    end
  end

  describe "move" do
    test "moves a task to another column", %{
      conn: conn,
      task_id: task_id,
      column_id: new_column_id,
      user: user
    } do
      conn = authenticate_request(conn, user)

      conn =
        put(conn, "/api/tasks/#{task_id}/move", %{"column_id" => Integer.to_string(new_column_id)})

      assert json_response(conn, 200)["data"]["column_id"] == new_column_id
    end
  end

  describe "clone" do
    test "clones a task successfully", %{conn: conn, task_id: task_id, user: user} do
      conn = authenticate_request(conn, user)
      conn = post(conn, "/api/tasks/#{task_id}/clone")
      assert json_response(conn, 200)["data"]["id"] != task_id
    end
  end

  describe "tasks_by_column_id" do
    test "lists tasks by column_id", %{conn: conn, column_id: column_id, user: user} do
      conn = authenticate_request(conn, user)
      conn = get(conn, "/api/columns/#{column_id}/tasks")
      assert json_response(conn, 200)["data"] |> length() > 0
    end
  end
end
