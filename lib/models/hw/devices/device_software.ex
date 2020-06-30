defmodule Dripio.DeviceSoftware do
  use Ecto.Schema
  import Ecto.Changeset
  use Dripio.Trace

  import Ecto.Query
  import Ecto.Changeset

  alias Dripio.Repo

  schema "device_software" do
    field(:version, :string)
    field(:description, :string)
    field(:documentation, :string)
    field(:bin, :binary)

    belongs_to(:device_model, Dripio.DeviceModel)

    timestamps()
  end

  @doc """
  Builds a changeset based on the `struct` and `params`.
  """
  def change_software(model, params \\ %{}) do
    Trace.wrap do
      model
      |> cast(params, [:version, :description, :documentation])
      |> validate_required([:version])
    end
  end

  def create_software(model, params \\ %{}) do
    Trace.wrap do
      model
      |> change_software(params)
      |> cast(params, [:bin, :device_model_id])
      |> validate_required([:bin, :device_model_id])
      |> foreign_key_constraint(:device_model_id)
    end
  end

  #

  def get_by_id(id) do
    Trace.wrap do
      # TODO: should not load bin if not necessary
      Repo.get(Dripio.DeviceSoftware, id)
    end
  end

  def get_by_model_id(model_id) do
    Trace.wrap do
      Repo.all(
        from(s in Dripio.DeviceSoftware,
          where: s.device_model_id == ^model_id,
          select: %{
            id: s.id,
            device_model_id: s.device_model_id,
            version: s.version,
            description: s.description,
            documentation: s.documentation
          }
        )
      )
    end
  end

  def get() do
    Repo.all(
      from(s in Dripio.DeviceSoftware,
        select: %{
          id: s.id,
          device_model_id: s.device_model_id,
          version: s.version,
          description: s.description,
          documentation: s.documentation
        }
      )
    )
  end

  #

  def export(device_sw) do
    %{
      id: device_sw.id,
      model_id: device_sw.device_model_id,
      version: device_sw.version,
      description: device_sw.description,
      documentation: device_sw.documentation
    }
  end
end
