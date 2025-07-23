defmodule Hinomix.Repo do
  use Ecto.Repo,
    otp_app: :hinomix,
    adapter: Ecto.Adapters.Postgres
end
