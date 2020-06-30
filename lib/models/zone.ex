defmodule Dripio.Zone do
  use Ecto.Schema
  import Ecto.Query
  import Ecto.Changeset
  use Dripio.Trace

  alias Dripio.Location
  alias Dripio.Zone
  alias Dripio.Repo

  @primary_key {:id, Ecto.ShortUUID, autogenerate: true}

  schema "zones" do
    field(:title, :string)

    belongs_to(:location, Dripio.Location, type: Ecto.ShortUUID)
    belongs_to(:parent, Dripio.Zone, type: Ecto.ShortUUID)

    timestamps()
  end

  @doc """
  Builds a changeset based on the `struct` and `params`.
  """
  def change_zone(struct, params \\ %{}) do
    Trace.wrap do
      struct
      |> cast(params, [:title, :location_id])
      |> validate_required([:title, :location_id])
      |> foreign_key_constraint(:location_id)
    end
  end

  def create_zone(struct, params \\ %{}) do
    change_zone(struct, params)
    |> cast(params, [:parent_id])
    |> foreign_key_constraint(:parent_id)
  end

  #

  def get(opts) do
    Trace.wrap do
      case get_all(opts) do
        [%Dripio.Zone{} = d | _] -> d
        %Dripio.Zone{} = d -> d
        _ -> nil
      end
    end
  end

  def get_all(opts) do
    Trace.wrap do
      _get_all(opts)
    end
  catch
    _ -> :error
    _, _ -> :error
  end

  defp _get_all(%{user_id: user_id, location_id: location_id, zone_id: zone_id}) do
    if Location.check_owner(user_id, location_id) do
      get(%{location_id: location_id, zone_id: zone_id})
    else
      raise "Zone #{zone_id} does not belong to location #{location_id}"
    end
  end

  defp _get_all(%{location_id: :undefined, zone_id: zone_id}) do
    Repo.all(
      from(d in Zone,
        where: d.id == ^zone_id
      )
    )
  end

  defp _get_all(%{location_id: location_id, zone_id: zone_id}) do
    Repo.all(
      from(d in Zone,
        where: d.id == ^zone_id,
        where: d.location_id == ^location_id
      )
    )
  end

  defp _get_all(%{user_id: user_id, location_id: location_id}) do
    if Location.check_owner(user_id, location_id) do
      Repo.all(
        from(d in Zone,
          where: d.location_id == ^location_id
        )
      )
    else
      raise "User #{user_id} have no rights to access location #{location_id}"
    end
  end

  defp _get_all(%{location_id: :undefined}) do
    Repo.all(Zone)
  end

  defp _get_all(%{location_id: location_id}) do
    Repo.all(
      from(d in Zone,
        where: d.location_id == ^location_id
      )
    )
  end

  defp _get_all(%{zone_id: zone_id}) do
    Repo.get(Dripio.Zone, zone_id)
  end

  defp _get_all(zone_id) when is_binary(zone_id) do
    _get_all(%{zone_id: zone_id})
  end

  #

  def export(zone) do
    %{
      id: zone.id,
      title: zone.title,
      parent: zone.parent_id,
      location: zone.location_id
    }
  end
end
