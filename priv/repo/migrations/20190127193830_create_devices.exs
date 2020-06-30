defmodule Dripio.Repo.Migrations.CreateDevices do
  use Ecto.Migration

  def change do
    create table(:lots, primary_key: false) do
      add(:id, :uuid, primary_key: true)
      add(:manufacturer, :string)
      add(:manufacturing_date, :string)
      add(:manufacturing_code, :string)

      timestamps()
    end

    create table(:device_types) do
      add(:title, :string)
      add(:description, :string)

      timestamps()
    end

    create table(:device_models) do
      add(:title, :string, null: false)
      add(:description, :string)
      add(:schematics, :string)
      add(:documentation, :string)

      add(:device_type_id, references(:device_types, on_delete: :delete_all), null: false)

      timestamps()
    end

    create table(:device_software) do
      add(:version, :string)
      add(:description, :string)
      add(:documentation, :string)

      add(:device_model_id, references(:device_models, on_delete: :delete_all), null: false)

      timestamps()
    end

    create table(:devices, primary_key: false) do
      add(:id, :uuid, primary_key: true)
      add(:title, :string)
      add(:status, :boolean)
      add(:mcu_status, :boolean)
      add(:mcu_errors, {:array, :binary})
      add(:data, :map)
      add(:notes, :string)

      add(:device_model_id, references(:device_models), null: false)
      add(:location_id, references(:locations, type: :uuid, on_delete: :delete_all), null: false)
      add(:software_id, references(:device_software))
      add(:lot_id, references(:lots, type: :uuid))

      timestamps()
    end
  end
end
