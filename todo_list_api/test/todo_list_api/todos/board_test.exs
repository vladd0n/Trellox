defmodule TodoListApi.Todos.BoardTest do
  use ExUnit.Case, async: true
  use TodoListApi.DataCase

  alias TodoListApi.Todos
  alias TodoListApi.Todos.Board
  alias TodoListApi.Repo

  @valid_board_attrs %{name: "Test Board", background: "A test board"}
  @invalid_board_attrs %{name: "", background: ""}

  test "create_board/1 with valid attributes" do
    {:ok, board} = Todos.create_board(@valid_board_attrs)
    board = Repo.get!(Board, board.id)

    assert board.name == "Test Board"
    assert board.background == "A test board"
  end

  test "create_board/1 with invalid attributes" do
    {:error, changeset} = Todos.create_board(@invalid_board_attrs)

    assert changeset.errors == [
             name: {"can't be blank", [{:validation, :required}]},
             background: {"can't be blank", [{:validation, :required}]}
           ]
  end

  test "update_board/2 with valid attributes" do
    {:ok, board} = Todos.create_board(@valid_board_attrs)
    new_attrs = %{name: "Updated Board", background: "An updated test board"}

    {:ok, updated_board} = Todos.update_board(board.id, new_attrs)

    assert updated_board.name == "Updated Board"
    assert updated_board.background == "An updated test board"
  end

  test "update_board/2 with invalid attributes" do
    {:ok, board} = Todos.create_board(@valid_board_attrs)

    {:error, changeset} = Todos.update_board(board.id, @invalid_board_attrs)

    assert changeset.errors == [
             name: {"can't be blank", [{:validation, :required}]},
             background: {"can't be blank", [{:validation, :required}]}
           ]
  end

  test "delete_board/1" do
    {:ok, board} = Todos.create_board(@valid_board_attrs)
    {:ok, deleted_board} = Todos.delete_board(board.id)

    assert deleted_board.id == board.id

    assert_raise Ecto.NoResultsError, fn ->
      Repo.get!(Board, board.id)
    end
  end
end
