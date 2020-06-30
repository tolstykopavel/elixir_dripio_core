defmodule Dripio.DeviceType do
  use Ecto.Schema
  import Ecto.Changeset
  use Dripio.Trace
  alias Dripio.Repo

  schema "device_types" do
    field(:title, :string)
    field(:description, :string)

    has_many(:device_models, Dripio.DeviceModel)

    timestamps()
  end

  @doc """
  Builds a changeset based on the `struct` and `params`.
  """
  def change_device_type(struct, params \\ %{}) do
    Trace.wrap do
      struct
      |> cast(params, [:title, :description])
      |> validate_required([:title])
    end
  end

  def create_device_type(struct, params \\ %{}) do
    Trace.wrap do
      struct
      |> change_device_type(params)
    end
  end

  #

  def get() do
    Repo.all(Dripio.DeviceType)
  end

  def get_by_id(id) do
    Trace.wrap do
      Repo.get(Dripio.DeviceType, id)
    end
  end

  #

  def export(device_type) do
    %{
      id: device_type.id,
      title: device_type.title,
      description: device_type.description
    }
  end
end
