defmodule TodoListApiWeb.AuthControllerTest do
  use TodoListApiWeb.ConnCase

  alias TodoListApi.Todos
  alias TodoListApi.Guardian

  setup do
    conn = build_conn()

    {:ok, user} =
      Todos.create_user(%{
        login: "test@example.com",
        password: "password",
        nick: "Test User",
        email: "test@example.com"
      })

    %{conn: conn, user: user}
  end

  # Tests go here
end
