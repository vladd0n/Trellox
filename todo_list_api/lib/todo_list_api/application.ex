defmodule TodoListApi.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      # Start the Telemetry supervisor
      TodoListApiWeb.Telemetry,
      # Start the Ecto repository
      TodoListApi.Repo,
      # Start the PubSub system
      {Phoenix.PubSub, name: TodoListApi.PubSub},
      # Start Finch
      {Finch, name: TodoListApi.Finch},
      # Start the Endpoint (http/https)
      TodoListApiWeb.Endpoint
      # Start a worker by calling: TodoListApi.Worker.start_link(arg)
      # {TodoListApi.Worker, arg}
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: TodoListApi.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    TodoListApiWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
