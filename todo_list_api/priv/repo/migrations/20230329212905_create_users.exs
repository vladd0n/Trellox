defmodule TodoListApi.Repo.Migrations.CreateUsers do
  use Ecto.Migration

  def change do
    create table(:users) do
      add :email, :string, null: false
      add :login, :string, null: false
      add :nick, :string, null: false
      add :password_hash, :string, null: false
      add :title, :string
      add :company, :string

      timestamps()
    end

    create unique_index(:users, [:email])
    create unique_index(:users, [:login])
  end
end
