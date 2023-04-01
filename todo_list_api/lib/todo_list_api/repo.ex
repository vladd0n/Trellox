defmodule TodoListApi.Repo do
  use Ecto.Repo,
    otp_app: :todo_list_api,
    adapter: Ecto.Adapters.Postgres
end
