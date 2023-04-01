defmodule TodoListApiWeb.BoardControllerTest do
  use TodoListApiWeb.ConnCase

  alias TodoListApi.Todos
  # alias TodoListApi.Guardian

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

    %{conn: conn, user: user}
  end

  test "index/2 lists all boards", %{conn: conn, user: user} do
    # Generate the token for the user
    # {:ok, token, _claims} = Guardian.encode_and_sign(user)

    # # Add the token to the request headers
    # conn = conn
    # |> put_req_header("authorization", "Bearer #{token}")
    # # Authenticate the request
    # conn = authenticate_request(conn, user)
    conn = authenticate_request(conn, user)
    # Insert some sample data
    {:ok, board1} =
      Todos.create_board(%{"name" => "Board 1", "background" => "blue", "columns_count" => 2})

    {:ok, board2} =
      Todos.create_board(%{"name" => "Board 2", "background" => "green", "columns_count" => 3})

    # Make a request to the index action
    conn = get(conn, "/api/boards")

    # Check the response status and payload
    assert json_response(conn, 200)["data"] == [
             %{"id" => board1.id, "name" => "Board 1", "background" => "blue"},
             %{"id" => board2.id, "name" => "Board 2", "background" => "green"}
           ]
  end

  ## Test for the 'show' action
  test "show/2 returns a specific board", %{conn: conn, user: user} do
    conn = authenticate_request(conn, user)
    # Insert a sample board
    {:ok, board} =
      Todos.create_board(%{"name" => "Board", "background" => "blue", "columns_count" => 2})

    # Make a request to the show action
    # conn = get(conn, Routes.board_path(conn, :show, board.id))
    conn = get(conn, "/api/boards/#{board.id}")

    # Check the response status and payload
    assert json_response(conn, 200)["data"] == %{
             "id" => board.id,
             "name" => "Board",
             "background" => "blue"
           }
  end

  test "show/2 returns not found when board doesn't exist", %{conn: conn, user: user} do
    conn = authenticate_request(conn, user)
    # Make a request to the show action with a non-existing ID
    # conn = get(conn, Routes.board_path(conn, :show, -1))
    conn = get(conn, "/api/boards/-1")

    # Check the response status and error message
    assert json_response(conn, 404) == %{"error" => "Board not found"}
  end

  ## Test for the 'create' action
  test "create/2 creates a new board", %{conn: conn, user: user} do
    conn = authenticate_request(conn, user)
    # Make a request to the create action
    # conn = post(conn, Routes.board_path(conn, :create), %{"name" => "New Board", "background" => "yellow", "columns_count" => 2})
    conn =
      post(conn, "/api/boards", %{
        "name" => "New Board",
        "background" => "yellow",
        "columns_count" => 2
      })

    # Check the response status and payload
    board = json_response(conn, 201)["data"]
    assert board["name"] == "New Board"
    assert board["background"] == "yellow"

    # Check if the board was actually created
    assert Todos.get_board!(board["id"]).id == board["id"]
  end

  ## Test for the update action
  test "update/2 updates a board", %{conn: conn, user: user} do
    conn = authenticate_request(conn, user)
    # Insert a sample board
    {:ok, board} =
      Todos.create_board(%{"name" => "Board", "background" => "blue", "columns_count" => 2})

    # Make a request to the update action
    # conn = put(conn, Routes.board_path(conn, :update, board.id), %{"board" => %{"name" => "Updated Board", "background" => "green"}})
    conn =
      put(conn, "/api/boards/#{board.id}", %{
        "board" => %{"name" => "Updated Board", "background" => "green"}
      })

    # Check the response status and payload
    updated_board = json_response(conn, 200)["data"]
    assert updated_board["name"] == "Updated Board"
    assert updated_board["background"] == "green"

    # Check if the board was actually updated
    board_from_db = Todos.get_board!(board.id)
    assert board_from_db.name == "Updated Board"
    assert board_from_db.background == "green"
  end

  test "update/2 returns not found when board doesn't exist", %{conn: conn, user: user} do
    conn = authenticate_request(conn, user)
    # Make a request to the update action with a non-existing ID
    # conn = put(conn, Routes.board_path(conn, :update, -1), %{"board" => %{"name" => "Updated Board", "background" => "green"}})
    conn =
      put(conn, "/api/boards/-1", %{
        "board" => %{"name" => "Updated Board", "background" => "green"}
      })

    # Check the response status and error message
    assert json_response(conn, 404) == %{"error" => "Board not found"}
  end

  test "update/2 returns unprocessable entity when data is invalid", %{conn: conn, user: user} do
    conn = authenticate_request(conn, user)
    # Insert a sample board
    {:ok, board} =
      Todos.create_board(%{"name" => "Board", "background" => "blue", "columns_count" => 2})

    # Make a request to the update action with invalid data
    # conn = put(conn, Routes.board_path(conn, :update, board.id), %{"board" => %{"name" => "", "background" => ""}})
    conn = put(conn, "/api/boards/#{board.id}", %{"board" => %{"name" => "", "background" => ""}})

    # Check the response status and error message
    assert json_response(conn, 422) == %{
             "error" => "Invalid data",
             "details" => %{"background" => ["can't be blank"], "name" => ["can't be blank"]}
           }
  end

  ## Test for the delete action
  test "delete/2 deletes a board", %{conn: conn, user: user} do
    conn = authenticate_request(conn, user)
    # Insert a sample board
    {:ok, board} =
      Todos.create_board(%{"name" => "Board", "background" => "blue", "columns_count" => 2})

    # Make a request to the delete action
    # conn = delete(conn, Routes.board_path(conn, :delete, board.id))
    conn = delete(conn, "/api/boards/#{board.id}")

    # Check the response status
    assert conn.status == 204

    # Check if the board was actually deleted
    assert_raise Ecto.NoResultsError, fn ->
      Todos.get_board!(board.id)
    end
  end

  test "delete/2 returns not found when board doesn't exist", %{conn: conn, user: user} do
    conn = authenticate_request(conn, user)
    # Make a request to the delete action with a non-existing ID
    # conn = delete(conn, Routes.board_path(conn, :delete, -1))
    conn = delete(conn, "/api/boards/-1")

    # Check the response status and error message
    assert json_response(conn, 404) == %{"error" => "Board not found"}
  end
end
