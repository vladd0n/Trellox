defmodule TodoListApi.Todos.UserTest do
  use ExUnit.Case, async: true
  use TodoListApi.DataCase

  alias TodoListApi.Todos
  alias TodoListApi.Todos.User
  alias TodoListApi.Repo

  @valid_user_attrs %{
    email: "test@example.com",
    login: "test_user",
    password: "test_password",
    nick: "Test User"
  }
  @invalid_user_attrs %{email: "", login: "", password: "", nick: ""}
  @updated_user_attrs %{
    email: "updated@example.com",
    login: "updated_user",
    password: "updated_password",
    nick: "Updated User"
  }

  test "create_user/1 with valid attributes" do
    {:ok, user} = Todos.create_user(@valid_user_attrs)
    user = Repo.get!(User, user.id)

    assert user.email == "test@example.com"
    assert user.login == "test_user"
    assert user.nick == "Test User"
  end

  test "create_user/1 with invalid attributes" do
    {:error, changeset} = Todos.create_user(@invalid_user_attrs)

    assert changeset.errors == [
             login: {"can't be blank", [{:validation, :required}]},
             password: {"can't be blank", [{:validation, :required}]},
             nick: {"can't be blank", [{:validation, :required}]},
             email: {"can't be blank", [{:validation, :required}]}
           ]
  end

  test "update_user/2 with valid attributes" do
    {:ok, user} = Todos.create_user(@valid_user_attrs)
    {:ok, updated_user} = Todos.update_user(user.id, @updated_user_attrs)

    # Load the updated user from the database
    updated_user = Repo.get!(User, updated_user.id)

    assert updated_user.email == "updated@example.com"
    assert updated_user.login == "updated_user"
    assert updated_user.nick == "Updated User"

    # Check if the password_hash is updated
    assert updated_user.password_hash != user.password_hash
  end

  test "update_user/2 with invalid attributes" do
    {:ok, user} = Todos.create_user(@valid_user_attrs)

    invalid_attrs = %{
      email: "",
      login: "",
      password: "",
      nick: ""
    }

    {:error, changeset} = Todos.update_user(user.id, invalid_attrs)

    assert changeset.errors == [
             login: {"can't be blank", [{:validation, :required}]},
             password: {"can't be blank", [{:validation, :required}]},
             nick: {"can't be blank", [{:validation, :required}]},
             email: {"can't be blank", [{:validation, :required}]}
           ]
  end

  test "delete_user/1" do
    {:ok, user} = Todos.create_user(@valid_user_attrs)

    {:ok, deleted_user} = Todos.delete_user(user.id)
    assert deleted_user.id == user.id
    assert Repo.get(User, user.id) == nil
  end

  test "get_user!/1" do
    {:ok, user} = Todos.create_user(@valid_user_attrs)

    fetched_user = Todos.get_user!(user.id)
    assert fetched_user.id == user.id
  end

  test "list_users/0" do
    {:ok, user1} = Todos.create_user(@valid_user_attrs)

    {:ok, user2} =
      Todos.create_user(%{@valid_user_attrs | email: "test2@example.com", login: "test_user2"})

    users = Todos.list_users()

    assert length(users) == 2

    assert %TodoListApi.Todos.User{id: id1, login: login1, email: email1, nick: nick1} =
             Enum.find(users, fn user -> user.id == user1.id end)

    assert %TodoListApi.Todos.User{id: id2, login: login2, email: email2, nick: nick2} =
             Enum.find(users, fn user -> user.id == user2.id end)

    assert id1 == user1.id
    assert login1 == user1.login
    assert email1 == user1.email
    assert nick1 == user1.nick

    assert id2 == user2.id
    assert login2 == user2.login
    assert email2 == user2.email
    assert nick2 == user2.nick
  end
end
