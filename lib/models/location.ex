defmodule Dripio.Location do
  use Ecto.Schema
  import Ecto.Changeset

  alias Dripio.Repo
  alias Dripio.Location
  use Dripio.Trace

  @primary_key {:id, Ecto.ShortUUID, autogenerate: true}

  schema "locations" do
    field(:title, :string, default: "No title")
    field(:address, :map, default: %{})
    field(:picture, :string)
    field(:auth_key, :string)

    belongs_to(:owner, Dripio.User, type: Ecto.ShortUUID)

    many_to_many(:users, Dripio.User,
      join_through: "users_locations",
      on_replace: :delete,
      on_delete: :delete_all
    )

    timestamps()
  end

  @doc """
  Builds a changeset based on the `struct` and `params`.
  """
  def change_location(model, params \\ %{}) do
    Trace.wrap do
      model
      |> cast(params, [:title, :address, :picture, :auth_key, :owner_id])
      |> decode_address
    end
  end

  def create_location(model, params \\ %{}) do
    Trace.wrap do
      model
      |> change_location(params)
      |> cast(params, [:id])
      |> validate_required([:title])
      |> maybe_assoc_owner(params)
    end
  end

  def share(model, %Dripio.User{} = user) do
    Trace.wrap do
      model = Repo.preload(model, :users)

      model
      |> cast(%{}, [])
      |> put_assoc(:users, model.users ++ [user])
    end
  end

  def unshare(model, %Dripio.User{} = user) do
    Trace.wrap do
      model = Repo.preload(model, :users)

      model
      |> cast(%{}, [])
      |> put_assoc(:users, model.users -- [user])
    end
  end

  defp maybe_assoc_owner(model, params) do
    Trace.wrap do
      case params do
        %{"owner_id" => owner_id} ->
          model
          |> foreign_key_constraint(:owner_id)
          |> put_assoc(:users, [Dripio.Repo.get(Dripio.User, owner_id)])

        _ ->
          model
      end
    end
  end

  defp decode_address(changeset) do
    Trace.wrap do
      case changeset do
        %Ecto.Changeset{changes: %{address: _address}} ->
          changeset

        # |> put_change(:address, Jason.decode!(address))

        _ ->
          changeset
      end
    end
  end

  #

  def get_by_id(id) do
    Trace.wrap do
      Repo.get(Location, id)
    end
  end

  def get_by_user_id(user_id) do
    Trace.wrap do
      Repo.all(Location)
      |> Repo.preload(:users)
      |> Enum.filter(fn g ->
        Enum.any?(g.users, fn u -> u.id == user_id end)
      end)
    end
  end

  def get_by_owner_id(user_id) do
    Trace.wrap do
      Repo.get_by(Location, owner_user_id: user_id)
    end
  end

  def check_owner(user_id, location_id) do
    Trace.wrap do
      case get_by_user_id(user_id)
           |> Enum.filter(fn g -> g.id == location_id end) do
        [_ | _] ->
          true

        _ ->
          false
      end
    end
  end

  #

  def export(location) do
    %{
      id: location.id,
      title: location.title,
      address: location.address,
      picture: location.picture,
      auth_key: location.auth_key,
      owner_user_id: location.owner_id,
      users: Enum.map(location.users, fn u -> u.id end)
    }
  end
end
