defmodule Dripio.Repo do
  use Ecto.Repo,
    otp_app: :dripio_core,
    adapter: Ecto.Adapters.Postgres
end
