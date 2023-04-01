defmodule TodoListApi.Repo.Migrations.CreateTasks do
  use Ecto.Migration

  def change do
    create table(:tasks) do
      add :title, :string
      add :description, :text
      add :is_complete, :boolean, default: false, null: false
      add :column_id, references(:columns, on_delete: :delete_all)

      timestamps()
    end
  end
end
