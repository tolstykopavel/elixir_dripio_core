defmodule Dripio.Repo.Migrations.CreateLotsAndZones do
  use Ecto.Migration

  def change do
    create table(:zones, primary_key: false) do
      add(:id, :uuid, primary_key: true)
      add(:title, :string)

      add(:parent_id, :uuid)
      add(:location_id, :uuid)

      timestamps()
    end
  end
end
