defmodule Dripio.HW.Lot do
  use Ecto.Schema
  import Ecto.Changeset
  use Dripio.Trace

  @primary_key {:id, Ecto.ShortUUID, autogenerate: true}

  schema "lot" do
    field(:manufacturer, :string)
    field(:manufacturing_date, :string)
    field(:manufacturing_code, :string)

    has_many(:peripherals, Dripio.Peripheral)
    has_many(:devices, Dripio.Device)

    timestamps()
  end

  @doc """
  Builds a changeset based on the `struct` and `params`.
  """
  def change_lot(struct, params \\ %{}) do
    Trace.wrap do
      struct
      |> cast(params, [:manufacturer, :manufacturing_date, :manufacturing_code])
      |> validate_required([:manufacturer, :manufacturing_date, :manufacturing_code])
    end
  end
end
