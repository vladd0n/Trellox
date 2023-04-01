defmodule TodoListApi.Repo.Migrations.CreateColumns do
  use Ecto.Migration

  def change do
    create table(:columns) do
      add :name, :string
      add :background, :string
      add :default_flag, :boolean, default: false
      add :position, :integer
      add :board_id, references(:boards, on_delete: :delete_all)

      timestamps()
    end

    create unique_index(:columns, [:board_id, :position], name: :columns_board_id_position_index)
  end
end
