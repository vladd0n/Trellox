defmodule TodoListApiWeb.Router do
  use TodoListApiWeb, :router

  pipeline :api do
    plug :accepts, ["json"]
  end

  # Add a new pipeline for authentication
  pipeline :authenticated do
    plug Guardian.Plug.VerifyHeader, scheme: "Bearer", module: TodoListApi.Guardian
    plug Guardian.Plug.VerifySession, scheme: "Bearer", module: TodoListApi.Guardian

    plug Guardian.Plug.LoadResource,
      module: TodoListApi.Guardian,
      error_handler: TodoListApiWeb.AuthErrorHandler
  end

  scope "/api", TodoListApiWeb, as: :api do
    pipe_through :api

    # Public routes
    resources "/users", UserController, only: [:index, :create, :show, :update, :delete]
    post "/signin", SessionController, :create
    post "/login", UserController, :login
    delete "/logout", UserController, :logout

    # Routes that require authentication
    pipe_through :authenticated
    resources "/tasks", TaskController, except: [:new, :edit]

    resources "/boards", BoardController, except: [:new, :edit] do
      resources "/columns", ColumnController, except: [:new, :edit]
    end

    get "/columns/:column_id/tasks", TaskController, :tasks_by_column_id
    post "/tasks/:id/clone", TaskController, :clone
    put "/tasks/:id/move", TaskController, :move
  end

  # Enable LiveDashboard and Swoosh mailbox preview in development
  if Application.compile_env(:todo_list_api, :dev_routes) do
    # If you want to use the LiveDashboard in production, you should put
    # it behind authentication and allow only admins to access it.
    # If your application does not have an admins-only section yet,
    # you can use Plug.BasicAuth to set up some basic authentication
    # as long as you are also using SSL (which you should anyway).
    import Phoenix.LiveDashboard.Router

    scope "/dev" do
      pipe_through [:fetch_session, :protect_from_forgery]

      live_dashboard "/dashboard", metrics: TodoListApiWeb.Telemetry
      forward "/mailbox", Plug.Swoosh.MailboxPreview
    end
  end
end
