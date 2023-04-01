defmodule TodoListApi.Todos.User do
  @moduledoc """
  User schema
  """
  use Ecto.Schema
  import Ecto.Changeset

  schema "users" do
    field :login, :string
    field :password, :string, virtual: true
    field :password_hash, :string
    field :nick, :string
    field :email, :string
    field :title, :string
    field :company, :string
    field :has_token?, :boolean, default: false, virtual: true

    timestamps()
  end

  @doc false
  def changeset(user, attrs) do
    user
    |> cast(attrs, [:login, :password, :nick, :email, :title, :company])
    |> validate_required([:login, :password, :nick, :email])
    |> unique_constraint(:login)
    |> unique_constraint(:email)
    |> hash_password()
  end

  defp hash_password(changeset) do
    case changeset do
      %Ecto.Changeset{valid?: true, changes: %{password: password}} ->
        put_change(changeset, :password_hash, Bcrypt.hash_pwd_salt(password))

      _ ->
        changeset
    end
  end
end
