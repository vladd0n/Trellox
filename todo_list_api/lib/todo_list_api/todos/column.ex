defmodule TodoListApi.Todos.Column do
  @moduledoc """
  Column schema
  """
  use Ecto.Schema
  import Ecto.Changeset

  schema "columns" do
    field :name, :string
    field :background, :string
    field :default_flag, :boolean, default: false
    # columns pos in the board (for ordering)
    field :position, :integer
    # assoc with board schema
    belongs_to :board, TodoListApi.Todos.Board
    has_many :tasks, TodoListApi.Todos.Task

    timestamps()
  end

  @doc false
  def changeset(column, attrs) do
    column
    |> cast(attrs, [:name, :background, :default_flag, :board_id, :position])
    |> validate_required([:name, :background, :board_id, :position])
    # imported from Ecto.Changeset
    # ensure 'board_id' is valid to an existing board
    |> foreign_key_constraint(:board_id)
    |> unique_constraint(:position, name: :columns_board_id_position_index, scope: :board_id)
  end
end
