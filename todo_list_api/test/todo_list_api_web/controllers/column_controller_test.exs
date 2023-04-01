defmodule TodoListApiWeb.ColumnControllerTest do
  @moduledoc false
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

    %{conn: conn, board: board, user: user}
  end

  test "index/2 lists all columns for a board", %{conn: conn, board: board, user: user} do
    conn = authenticate_request(conn, user)
    # Insert some sample columns
    {:ok, column1} =
      Todos.create_column(board.id, %{
        "name" => "Column 1",
        "background" => "blue",
        "position" => 1
      })

    {:ok, column2} =
      Todos.create_column(board.id, %{
        "name" => "Column 2",
        "background" => "green",
        "position" => 2
      })

    # Make a request to the index action
    conn = get(conn, "/api/boards/#{board.id}/columns")

    # Check the response status and payload
    assert json_response(conn, 200)["data"] == [
             %{
               "id" => column1.id,
               "name" => "Column 1",
               "background" => "blue",
               "board_id" => board.id
             },
             %{
               "id" => column2.id,
               "name" => "Column 2",
               "background" => "green",
               "board_id" => board.id
             }
           ]
  end

  # Test the show action
  test "show/2 displays a single column", %{conn: conn, board: board, user: user} do
    conn = authenticate_request(conn, user)

    {:ok, column} =
      Todos.create_column(board.id, %{
        "name" => "Sample Column",
        "background" => "blue",
        "position" => 1
      })

    conn = get(conn, "/api/boards/#{board.id}/columns/#{column.id}")

    assert json_response(conn, 200)["data"] == %{
             "id" => column.id,
             "name" => "Sample Column",
             "background" => "blue",
             "board_id" => board.id
           }
  end

  # Test the show action when the column doesn't exist
  test "show/2 returns not found when column doesn't exist", %{
    conn: conn,
    board: board,
    user: user
  } do
    conn = authenticate_request(conn, user)
    conn = get(conn, "/api/boards/#{board.id}/columns/-1")
    assert json_response(conn, 404) == %{"error" => "Column not found"}
  end

  # Test the create action
  test "create/2 creates a new column", %{conn: conn, board: board, user: user} do
    conn = authenticate_request(conn, user)

    conn =
      post(conn, "/api/boards/#{board.id}/columns", %{
        column: %{"name" => "New Column", "background" => "red", "position" => 1}
      })

    response = json_response(conn, 201)["data"]

    assert response == %{
             "id" => response["id"],
             "name" => "New Column",
             "background" => "red",
             "board_id" => board.id
           }
  end

  # Test the create action with invalid data
  test "create/2 returns unprocessable entity when data is invalid", %{
    conn: conn,
    board: board,
    user: user
  } do
    conn = authenticate_request(conn, user)

    conn =
      post(conn, "/api/boards/#{board.id}/columns", %{
        column: %{"name" => "", "background" => "", "position" => 1}
      })

    assert json_response(conn, 422) == %{
             "error" => "Invalid data",
             "details" => %{"background" => ["can't be blank"], "name" => ["can't be blank"]}
           }
  end

  # Test the update action
  test "update/2 updates an existing column", %{conn: conn, board: board, user: user} do
    conn = authenticate_request(conn, user)

    {:ok, column} =
      Todos.create_column(board.id, %{
        "name" => "Sample Column",
        "background" => "blue",
        "position" => 1
      })

    conn =
      put(conn, "/api/boards/#{board.id}/columns/#{column.id}", %{
        column: %{"name" => "Updated Column", "background" => "green"}
      })

    assert json_response(conn, 200)["data"] == %{
             "id" => column.id,
             "name" => "Updated Column",
             "background" => "green",
             "board_id" => board.id
           }
  end

  # Test the update action when the column doesn't exist
  test "update/2 returns not found when column doesn't exist", %{
    conn: conn,
    board: board,
    user: user
  } do
    conn = authenticate_request(conn, user)

    conn =
      put(conn, "/api/boards/#{board.id}/columns/-1", %{
        column: %{"name" => "Updated Column", "background" => "green"}
      })

    assert json_response(conn, 404) == %{"error" => "Column not found"}
  end

  # Test the update action with invalid data
  test "update/2 returns unprocessable entity when data is invalid", %{
    conn: conn,
    board: board,
    user: user
  } do
    conn = authenticate_request(conn, user)

    {:ok, column} =
      Todos.create_column(board.id, %{
        "name" => "Sample Column",
        "background" => "blue",
        "position" => 1
      })

    conn =
      put(conn, "/api/boards/#{board.id}/columns/#{column.id}", %{
        column: %{"name" => "", "background" => ""}
      })

    assert json_response(conn, 422) == %{
             "error" => "Invalid data",
             "details" => %{"background" => ["can't be blank"], "name" => ["can't be blank"]}
           }
  end

  # Test the delete action
  test "delete/2 deletes an existing column", %{conn: conn, board: board, user: user} do
    conn = authenticate_request(conn, user)

    {:ok, column} =
      Todos.create_column(board.id, %{
        "name" => "Sample Column",
        "background" => "blue",
        "position" => 1
      })

    conn = delete(conn, "/api/boards/#{board.id}/columns/#{column.id}")
    assert conn.status == 204
  end

  # Test the delete action when the column doesn't exist
  test "delete/2 returns not found when column doesn't exist", %{
    conn: conn,
    board: board,
    user: user
  } do
    conn = authenticate_request(conn, user)
    conn = delete(conn, "/api/boards/#{board.id}/columns/-1")
    assert json_response(conn, 404) == %{"error" => "Column not found"}
  end
end
