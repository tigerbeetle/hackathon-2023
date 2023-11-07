defmodule TigerSwarm.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      TigerSwarmWeb.Telemetry,
      {DNSCluster, query: Application.get_env(:tigerswarm, :dns_cluster_query) || :ignore},
      {Phoenix.PubSub, name: TigerSwarm.PubSub},
      # Start a worker by calling: TigerSwarm.Worker.start_link(arg)
      # {TigerSwarm.Worker, arg},
      # Start to serve requests, typically the last entry
      {TigerSwarm.Client.Supervisor,
       cluster_id: 0, addresses: ["3000"], concurrency_max: 4096, batch_size: 1},
      {Registry, keys: :unique, name: TigerSwarm.Beetle.Registry},
      {Task.Supervisor, name: TigerSwarm.Beetle.Supervisor},
      TigerSwarmWeb.Endpoint
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: TigerSwarm.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    TigerSwarmWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
