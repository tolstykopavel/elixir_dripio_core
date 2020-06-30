defmodule Dripio.DeviceModel do
  use Ecto.Schema
  import Ecto.Changeset
  use Dripio.Trace
  alias Dripio.Repo

  schema "device_models" do
    field(:title, :string)
    field(:description, :string)
    field(:schematics, :string)
    field(:documentation, :string)

    belongs_to(:device_type, Dripio.DeviceType)

    has_many(:devices, Dripio.Device)
    has_many(:software, Dripio.DeviceSoftware)

    timestamps()
  end

  @doc """
  Builds a changeset based on the `struct` and `params`.
  """
  def change_device_model(struct, params \\ %{}) do
    Trace.wrap do
      struct
      |> cast(params, [:title, :description, :schematics, :documentation, :device_type_id])
    end
  end

  def create_device_model(struct, params \\ %{}) do
    Trace.wrap do
      struct
      |> change_device_model(params)
      |> cast(params, [:device_type_id])
      |> validate_required([:title, :device_type_id])
      |> foreign_key_constraint(:device_type_id)
    end
  end

  #

  def get_by_id(id) do
    Trace.wrap do
      Repo.get(Dripio.DeviceModel, id)
    end
  end

  def get() do
    Repo.all(Dripio.DeviceModel)
  end

  #

  def export(device_model) do
    %{
      id: device_model.id,
      title: device_model.title,
      description: device_model.description,
      schematics: device_model.schematics,
      documentation: device_model.documentation,
      device_type_id: device_model.device_type_id
    }
  end
end
