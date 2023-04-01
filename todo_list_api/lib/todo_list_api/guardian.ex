defmodule TodoListApi.Guardian do
  @moduledoc false
  use Guardian, otp_app: :todo_list_api

  alias TodoListApi.Todos

  def subject_for_token(%{id: id} = _user, _claims) do
    {:ok, "User:#{id}"}
  end

  def subject_for_token(_, _) do
    {:error, :reason_for_error}
  end

  def resource_from_claims(%{"sub" => subject}) do
    case String.split(subject, ":") do
      ["User", id] ->
        case Todos.get_user!(String.to_integer(id)) do
          nil -> {:error, :not_found}
          user -> {:ok, user}
        end

      _ ->
        {:error, :invalid_claims}
    end
  end

  def resource_from_claims(_claims) do
    {:error, :invalid_claims}
  end
end
