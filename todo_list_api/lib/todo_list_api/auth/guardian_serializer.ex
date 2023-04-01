defmodule TodoListApi.Auth.GuardianSerializer do
  @moduledoc false
  @behaviour Guardian.Serializer

  alias TodoListApi.Todos.User
  alias TodoListApi.Repo

  def for_token(%User{} = user), do: {:ok, "User:#{user.id}"}
  def for_token(_), do: {:error, :impossible_to_serialize}

  def from_token("User:" <> id), do: {:ok, Repo.get(User, id)}
  def from_token(_), do: {:error, :invalid_token}
end
