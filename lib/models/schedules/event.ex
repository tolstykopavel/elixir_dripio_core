defmodule Dripio.Event do
  use Ecto.Schema
  # import Ecto.Query
  import Ecto.Changeset
  use Dripio.Trace

  @primary_key {:id, Ecto.ShortUUID, autogenerate: true}

  schema "events" do
    field(:title, :string)
    field(:timestamp, :utc_datetime)
    field(:algorithm, :map)
    field(:status, :string)
    field(:result, :map)
    field(:notes, :string)

    belongs_to(:schedule, Dripio.Schedule)
    belongs_to(:zone, Dripio.Zone)

    timestamps()
  end

  @doc """
  Builds a changeset based on the `struct` and `params`.
  """
  def change_event(struct, params \\ %{}) do
    Trace.wrap do
      struct
      |> cast(params, [
        :title,
        :timestamp,
        :algorithm,
        :status,
        :result,
        :notes,
        :schedule_id,
        :zone_id
      ])
      |> validate_required([:title, :timestamp, :algorithm, :zone_id])
      |> foreign_key_constraint(:zone_id)
    end
  end

  def create_event(struct, params \\ %{}) do
    change_event(struct, params)
  end
end
