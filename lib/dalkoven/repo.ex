defmodule Dalkoven.Repo do
  use Ecto.Repo,
    otp_app: :dalkoven,
    adapter: Ecto.Adapters.SQLite3
end
