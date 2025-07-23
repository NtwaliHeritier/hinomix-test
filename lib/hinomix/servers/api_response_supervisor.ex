defmodule Hinomix.Servers.ApiResponseSupervisor do
  use Supervisor

  def start_link(state \\ :ok) do
    Supervisor.start_link(__MODULE__, state, name: __MODULE__)
  end

  def init(_) do
    children = [
      {Hinomix.Servers.ApiResponseCache, []}
    ]

    opts = [strategy: :one_for_one]
    Supervisor.init(children, opts)
  end
end
