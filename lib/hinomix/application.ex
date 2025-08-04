defmodule Hinomix.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      HinomixWeb.Telemetry,
      Hinomix.Repo,
      {DNSCluster, query: Application.get_env(:hinomix, :dns_cluster_query) || :ignore},
      {Phoenix.PubSub, name: Hinomix.PubSub},
      # Start Oban
      {Oban, Application.fetch_env!(:hinomix, Oban)},
      # Start a worker by calling: Hinomix.Worker.start_link(arg)
      # {Hinomix.Worker, arg},
      # Start to serve requests, typically the last entry
      HinomixWeb.Endpoint,
      Hinomix.Servers.Supervisor
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Hinomix.Supervisor]
    result = Supervisor.start_link(children, opts)

    Hinomix.Jobs.ReportIngestionJob.new(%{})
    |> Oban.insert()

    Hinomix.Servers.Cache.update_state("max_pages", 7)

    result
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    HinomixWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
