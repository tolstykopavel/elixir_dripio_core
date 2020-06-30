defmodule Dripio.Schedule do
  use Ecto.Schema
  # import Ecto.Query
  # import Ecto.Changeset
  # use Dripio.Trace

  @primary_key {:id, Ecto.ShortUUID, autogenerate: true}

  schema "schedules" do
    field(:title, :string)
  end
end
