defmodule Guac.Repo do
  use Ecto.Repo,
    otp_app: :guac,
    adapter: Ecto.Adapters.Postgres
end
