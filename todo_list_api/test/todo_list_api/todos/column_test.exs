defmodule TodoListApi.Todos.ColumnTest do
  use ExUnit.Case, async: true
  use TodoListApi.DataCase

  alias TodoListApi.Todos
  alias TodoListApi.Todos.Column
  alias TodoListApi.Repo

  @valid_board_attrs %{name: "Test Board", background: "A test board"}
  @valid_column_attrs %{"name" => "Test Column", "background" => "A test column", "position" => 1}
  @invalid_column_attrs %{"name" => "", "background" => ""}

  def create_board! do
    {:ok, board} = Todos.create_board(@valid_board_attrs)
    board
  end

  test "create_column/2 with valid attributes" do
    board = create_board!()
    {:ok, column} = Todos.create_column(board.id, @valid_column_attrs)
    column = Repo.get!(Column, column.id)

    assert column.name == "Test Column"
    assert column.background == "A test column"
    assert column.board_id == board.id
  end

  test "create_column/2 with invalid attributes" do
    board = create_board!()

    {:error, changeset} = Todos.create_column(board.id, @invalid_column_attrs)

    assert changeset.errors == [
             name: {"can't be blank", [{:validation, :required}]},
             background: {"can't be blank", [{:validation, :required}]}
           ]
  end

  test "update_column/2 with valid attributes" do
    board = create_board!()
    {:ok, column} = Todos.create_column(board.id, @valid_column_attrs)

    updated_attrs = %{
      "name" => "Updated Column",
      "background" => "An updated test column",
      "position" => 2
    }

    {:ok, updated_column} = Todos.update_column(column.id, updated_attrs)

    assert updated_column.name == "Updated Column"
    assert updated_column.background == "An updated test column"
    assert updated_column.position == 2
  end

  test "update_column/2 with invalid attributes" do
    board = create_board!()
    {:ok, column} = Todos.create_column(board.id, @valid_column_attrs)

    {:error, changeset} = Todos.update_column(column.id, @invalid_column_attrs)

    assert changeset.errors == [
             name: {"can't be blank", [{:validation, :required}]},
             background: {"can't be blank", [{:validation, :required}]}
           ]
  end

  test "get_column/1" do
    board = create_board!()
    {:ok, column} = Todos.create_column(board.id, @valid_column_attrs)

    {:ok, fetched_column} = Todos.get_column(column.id)

    assert fetched_column.id == column.id
    assert fetched_column.name == "Test Column"
    assert fetched_column.background == "A test column"
  end

  test "get_column/1 with non-existing id" do
    assert {:error, :not_found} == Todos.get_column(-1)
  end

  test "delete_column/1" do
    board = create_board!()
    {:ok, column} = Todos.create_column(board.id, @valid_column_attrs)
    {:ok, deleted_column} = Todos.delete_column(column.id)

    assert deleted_column.id == column.id

    assert_raise Ecto.NoResultsError, fn ->
      Repo.get!(Column, column.id)
    end
  end
end
