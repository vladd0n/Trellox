defmodule TodoListApi.Todos.Board do
  @moduledoc """
  Board schema
  """
  use Ecto.Schema
  import Ecto.Changeset

  schema "boards" do
    field :name, :string
    field :background, :string
    # virtual field
    field :columns_count, :integer, virtual: true
    # relationship between Board and Column
    has_many :columns, TodoListApi.Todos.Column

    timestamps()
  end

  @doc false
  # board struct & map attrs
  def changeset(board, attrs) do
    board
    |> cast(attrs, [:name, :background])
    |> validate_required([:name, :background])
    # |> validate_max_columns() # <= 10
    # store the number of columns
    |> put_change(:columns_count, attrs["columns_count"] || 0)
    # |> validate_length(:columns_count, max: 10)
    |> validate_length_of_columns()
  end

  defp validate_length_of_columns(changeset) do
    columns_count = get_field(changeset, :columns_count)

    if columns_count > 10 do
      add_error(changeset, :columns, "cannot have more than 10 columns")
    else
      changeset
    end
  end

  # defp validate_max_columns(changeset) do
  #   cond do
  #     not changeset.valid? -> # if not valid -> unchanged
  #       changeset

  #     length(get_field(changeset, :columns)) > 10 -> # > 10 -> error
  #       add_error(changeset, :columns, "Board can have a maximum of 10 columns")

  #     true -> # no cond -> unchanged
  #       changeset
  #   end
  # end
end
