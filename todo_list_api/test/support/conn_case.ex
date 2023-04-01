defmodule TodoListApiWeb.ConnCase do
  @moduledoc false
  use ExUnit.CaseTemplate

  # Import Plug.Conn functions outside of the using block
  import Plug.Conn, only: [put_req_header: 3]

  using do
    quote do
      @endpoint TodoListApiWeb.Endpoint

      use TodoListApiWeb, :verified_routes
      import Plug.Conn
      import Phoenix.ConnTest
      alias TodoListApiWeb.Router.Api, as: Routes

      # Import the authenticate_request/2 function
      import TodoListApiWeb.ConnCase, only: [authenticate_request: 2]
    end
  end

  setup tags do
    TodoListApi.DataCase.setup_sandbox(tags)
    {:ok, conn: Phoenix.ConnTest.build_conn()}
  end

  def authenticate_request(conn, user) do
    {:ok, jwt, _claims} = TodoListApi.Guardian.encode_and_sign(user)

    conn
    |> put_req_header("authorization", "Bearer #{jwt}")
  end
end
