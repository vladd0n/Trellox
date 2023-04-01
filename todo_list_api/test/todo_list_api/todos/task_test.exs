defmodule TodoListApi.Todos.TaskTest do
  use ExUnit.Case, async: true
  use TodoListApi.DataCase

  alias TodoListApi.Todos
  alias TodoListApi.Todos.Task
  alias TodoListApi.Repo

  @valid_board_attrs %{name: "Test Board", background: "A test board"}
  @valid_column_attrs %{"name" => "Test Column", "background" => "A test column", "position" => 1}
  @valid_task_attrs %{
    "title" => "Test Task",
    "description" => "A test task",
    "is_complete" => false
  }
  @invalid_task_attrs %{"title" => "", "description" => "", "is_complete" => false}

  def create_board! do
    {:ok, board} = Todos.create_board(@valid_board_attrs)
    board
  end

  def create_column! do
    board = create_board!()
    {:ok, column} = Todos.create_column(board.id, @valid_column_attrs)
    column
  end

  test "create_task/2 with valid attributes" do
    column = create_column!()
    {:ok, task} = Todos.create_task(column.id, @valid_task_attrs)
    task = Repo.get!(Task, task.id)

    assert task.title == "Test Task"
    assert task.description == "A test task"
    assert task.is_complete == false
    assert task.column_id == column.id
  end

  test "create_task/2 with invalid attributes" do
    column = create_column!()
    {:error, changeset} = Todos.create_task(column.id, @invalid_task_attrs)

    refute changeset.valid?
    assert "can't be blank" in errors_on(changeset).title
  end
end
