defmodule Dripio.Repo.Migrations.CreatePeripherals do
  use Ecto.Migration

  def change do
    create table(:peripheral_types) do
      add :title, :string
      add :description, :string

      timestamps()
    end

    create table(:peripheral_models) do
      add :title, :string
      add :description, :string
      add :schematics, :string
      add :metadata_schema, :string
      add :documentation, :string

      add :peripheral_type_id, references(:peripheral_types, on_delete: :delete_all), null: false

      timestamps()
    end

    create table(:peripheral_software) do
      add :version, :string
      add :description, :string
      add :documentation, :string

      add :peripheral_model_id, references(:peripheral_models, on_delete: :delete_all), null: false

      timestamps()
    end

    create table(:peripherals, primary_key: false) do
      add :id, :uuid, primary_key: true
      add :title, :string
      add :status, :boolean
      add :local_address, :string
      add :notes, :string

      add :device_id, references(:devices, type: :uuid, on_delete: :delete_all)
      add :zone_id, references(:zones, type: :uuid, on_delete: :delete_all)
      add :lot_id, references(:lots, type: :uuid, on_delete: :delete_all)
      add :software_id, references(:peripheral_models, on_delete: :delete_all)
      add :peripheral_model_id, references(:peripheral_software, on_delete: :delete_all), null: false

      timestamps()
    end
  end
end
