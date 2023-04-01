defmodule TodoListApiWeb.UserControllerTest do
  @moduledoc false
  use TodoListApiWeb.ConnCase

  alias TodoListApi.Todos

  @valid_attrs %{
    "email" => "test@example.com",
    "password" => "password123",
    "login" => "testuser",
    "nick" => "Test User",
    "title" => "Developer",
    "company" => "Test Company"
  }
  @invalid_attrs %{"email" => "", "password" => ""}

  setup do
    conn = build_conn()
    %{conn: conn}
  end

  test "index/2 lists all users", %{conn: conn} do
    {:ok, user} = Todos.create_user(@valid_attrs)

    conn = get(conn, "/api/users")

    assert json_response(conn, 200)["data"] == [
             %{
               "id" => user.id,
               "email" => user.email,
               "login" => user.login,
               "nick" => user.nick,
               "title" => user.title,
               "company" => user.company
             }
           ]
  end

  test "show/2 returns a specific user", %{conn: conn} do
    {:ok, user} = Todos.create_user(@valid_attrs)

    conn = get(conn, "/api/users/#{user.id}")

    assert json_response(conn, 200)["data"] == %{
             "id" => user.id,
             "email" => user.email,
             "login" => user.login,
             "nick" => user.nick,
             "title" => user.title,
             "company" => user.company
           }
  end

  test "show/2 returns not found when user doesn't exist", %{conn: conn} do
    conn = get(conn, "/api/users/-1")
    assert json_response(conn, 404) == %{"error" => "User not found"}
  end

  test "create/2 creates a new user with valid attributes", %{conn: conn} do
    conn = post(conn, "/api/users", user: @valid_attrs)

    user = json_response(conn, 201)["data"]
    assert user["email"] == "test@example.com"
    assert user["login"] == "testuser"
    assert user["nick"] == "Test User"
    assert user["title"] == "Developer"
    assert user["company"] == "Test Company"
    assert Todos.get_user!(user["id"]).email == "test@example.com"
  end

  test "create/2 returns unprocessable entity when data is invalid", %{conn: conn} do
    conn = post(conn, "/api/users", user: @invalid_attrs)

    assert json_response(conn, 422) == %{
             "error" => "Invalid data",
             "details" => %{
               "email" => ["can't be blank"],
               "password" => ["can't be blank"],
               "login" => ["can't be blank"],
               "nick" => ["can't be blank"]
             }
           }
  end

  test "update/2 with valid data updates the user", %{conn: conn} do
    # Insert a sample user
    {:ok, user} = Todos.create_user(@valid_attrs)

    # Make a request to the update action with updated attributes
    updated_attrs = %{
      "email" => "updated@example.com",
      "nick" => "Updated User",
      "password" => "password123"
    }

    conn = put(conn, "/api/users/#{user.id}", user: updated_attrs)

    # Check the response status and payload
    assert json_response(conn, 200)["data"] == %{
             "id" => user.id,
             "email" => "updated@example.com",
             "login" => user.login,
             "nick" => "Updated User",
             "title" => user.title,
             "company" => user.company
           }
  end

  test "update/2 with invalid data returns an error", %{conn: conn} do
    # Insert a sample user
    {:ok, user} = Todos.create_user(@valid_attrs)

    # Make a request to the update action
    conn = put(conn, "/api/users/#{user.id}", user: %{"email" => ""})

    # Check the response status and payload
    assert json_response(conn, 422)["errors"] != %{}
  end

  test "delete/2 deletes the user", %{conn: conn} do
    # Insert a sample user
    {:ok, user} = Todos.create_user(@valid_attrs)

    # Make a request to the delete action
    conn = delete(conn, "/api/users/#{user.id}")

    # Check the response status and payload
    assert json_response(conn, 200)["data"] == %{
             "id" => user.id,
             "email" => user.email,
             "login" => user.login,
             "nick" => user.nick,
             "title" => user.title,
             "company" => user.company
           }

    # Make sure the user is not in the database anymore
    assert Todos.get_user(user.id) == {:error, :not_found}
  end

  test "delete/2 returns not found when user doesn't exist", %{conn: conn} do
    conn = delete(conn, "/api/users/-1")
    assert json_response(conn, 404) == %{"error" => "User not found"}
  end
end
