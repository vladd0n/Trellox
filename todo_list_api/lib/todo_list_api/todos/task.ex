defmodule TodoListApi.Todos.Task do
  @moduledoc """
  Task schema
  """
  use Ecto.Schema
  import Ecto.Changeset

  schema "tasks" do
    field :title, :string
    # Add this line
    field :description, :string
    # Change this line
    field :is_complete, :boolean, default: false
    belongs_to :column, TodoListApi.Todos.Column

    timestamps()
  end

  @doc false
  def changeset(task, attrs) do
    task
    # Change this line
    |> cast(attrs, [:title, :description, :is_complete, :column_id])
    |> validate_required([:title, :is_complete, :column_id])
    |> unique_constraint(:title, name: :tasks_title_column_id_index, scope: :column_id)
    |> foreign_key_constraint(:column_id)
  end
end
