defmodule ExBank.Application do
  # See https://elixir.hexdocs.pm/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      ExBankWeb.Telemetry,
      ExBank.Repo,
      {DNSCluster, query: Application.get_env(:ex_bank, :dns_cluster_query) || :ignore},
      {Phoenix.PubSub, name: ExBank.PubSub},
      # Start a worker by calling: ExBank.Worker.start_link(arg)
      # {ExBank.Worker, arg},
      # Start to serve requests, typically the last entry
      ExBankWeb.Endpoint
    ]

    # See https://elixir.hexdocs.pm/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: ExBank.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    ExBankWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
