defmodule Guac.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      # Start the Ecto repository
      Guac.Repo,
      # Start the Telemetry supervisor
      GuacWeb.Telemetry,
      # Start the PubSub system
      {Phoenix.PubSub, name: Guac.PubSub},
      # Supervisor for CSV Import
      {Task.Supervisor, name: Guac.CSV.ImportSupervisor},
      # Start the Endpoint (http/https)
      GuacWeb.Endpoint
      # Start a worker by calling: Guac.Worker.start_link(arg)
      # {Guac.Worker, arg}
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Guac.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    GuacWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
