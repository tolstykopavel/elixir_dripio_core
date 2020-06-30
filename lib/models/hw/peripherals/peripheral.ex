defmodule Dripio.Peripheral do
  use Ecto.Schema
  import Ecto.Changeset
  use Dripio.Trace

  alias Dripio.Repo

  @primary_key {:id, Ecto.ShortUUID, autogenerate: true}

  schema "peripheral" do
    field(:title, :string)
    field(:status, :string)
    field(:notes, :string)
    field(:local_address, :string)
    field(:metadata, :string)

    belongs_to(:peripheral_model, Dripio.PeripheralModel)
    belongs_to(:device, Dripio.Device, type: Ecto.ShortUUID)
    belongs_to(:zone, Dripio.Zone, type: Ecto.ShortUUID)
    belongs_to(:lot, Dripio.HW.Lot, type: Ecto.ShortUUID)

    timestamps()
  end

  @doc """
  Builds a changeset based on the `struct` and `params`.
  """

  def change_peripheral(model, params \\ %{}) do
    Trace.wrap do
      model
      |> cast(params, [
        :title,
        :status,
        :notes,
        :peripheral_model_id,
        :device_id,
        :zone_id,
        :lot_id
      ])
      |> foreign_key_constraint(:device_id)
      |> assign_zone(params)
    end
  end

  def create_peripheral(model, params \\ %{}) do
    Trace.wrap do
      model
      |> cast(params, [:id])
      |> change_peripheral(params)
      |> validate_required([:device_id, :peripheral_model_id])
      |> foreign_key_constraint(:peripheral_model_id)
      |> foreign_key_constraint(:lot_id)
    end
  end

  #

  defp assign_zone(changeset, params) do
    Trace.wrap do
      case params do
        %{zone_id: _zone_id} ->
          changeset
          |> cast(params, [:zone_id])
          |> foreign_key_constraint(:zone_id)

        _ ->
          changeset
      end
    end
  end

  #

  def get_by_id(id) do
    Trace.wrap do
      Repo.get(Dripio.Peripheral, id)
    end
  end
end
