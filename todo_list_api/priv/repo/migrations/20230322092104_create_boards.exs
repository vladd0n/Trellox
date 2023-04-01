defmodule TodoListApi.Repo.Migrations.CreateBoards do
  use Ecto.Migration

  def change do
    create table(:boards) do
      add :name, :string
      add :background, :string

      timestamps()
    end
  end
end
