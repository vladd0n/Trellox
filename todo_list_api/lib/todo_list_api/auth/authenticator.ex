defmodule TodoListApi.Auth.Authenticator do
  @moduledoc false
  use Guardian, otp_app: :todo_list_api

  alias TodoListApi.Todos.User
  alias TodoListApi.Repo

  def subject_for_token(user, _claims) do
    {:ok, to_string(user.id)}
  end

  def resource_from_claims(%{"sub" => id}) do
    case Repo.get(User, id) do
      nil -> {:error, :resource_not_found}
      user -> {:ok, user}
    end
  end
end
