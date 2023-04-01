defmodule TodoListApi.TodosFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `TodoListApi.Todos` context.
  """

  @doc """
  Generate a task with default attributes or with given attributes.
  """
  def task_fixture(attrs \\ %{}) do
    # Define default attributes
    default_attrs = %{
      completed: false,
      description: "some description",
      title: "some title"
    }

    # Merge given attributes with default attributes
    merged_attrs = Map.merge(default_attrs, attrs)

    # Create a board
    {:ok, board} = TodoListApi.Todos.create_board(%{name: "Test Board"})

    # Create a column
    {:ok, column} =
      TodoListApi.Todos.create_column(board.id, %{name: "Test Column", default_flag: :none})

    # Create task with 'column_id' or 'default_flag' and merged attributes
    {:ok, task} = TodoListApi.Todos.create_task(column.id, merged_attrs)

    task
  end
end
