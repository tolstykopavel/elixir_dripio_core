defmodule Dripio.Repo.Migrations.CreateLocations do
  use Ecto.Migration

  def change do
    create table(:locations, primary_key: false) do
      add :id, :uuid, primary_key: true
      add :title, :string
      add :address, :string
      add :picture, :text

      add :auth_key, :string

      add :owner_id, references(:users, type: :uuid, on_delete: :delete_all)

      timestamps()
    end
    # create index(:locations, [:user_id])
#

    create table(:users_locations, primary_key: false) do
      add :user_id, references(:users, type: :uuid, on_delete: :delete_all)
      add :location_id, references(:locations, type: :uuid, on_delete: :delete_all)
    end
  end
end
