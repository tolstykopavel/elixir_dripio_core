defmodule Dripio.Repo.Migrations.CreateSchedulingEvents do
  use Ecto.Migration

  def change do
    create table(:algorithm_templates, primary_key: false) do
      add(:id, :uuid, primary_key: true)
      add(:title, :string)
      add(:definition, :jsonb)
      add(:parameters_schema, :jsonb)
      add(:metadata, :jsonb)
      add(:notes, :string)
    end

    create table(:schedules, primary_key: false) do
      add(:id, :uuid, primary_key: true)

      add(:title, :string)
      add(:scheduling_rule, :string)
      add(:notes, :string)

      add(
        :algorithm_template_id,
        references(:algorithm_templates, type: :uuid, on_delete: :delete_all),
        null: false
      )

      add(:zone_id, references(:zones, type: :uuid, on_delete: :delete_all), null: false)

      timestamps()
    end

    create table(:events, primary_key: false) do
      add(:id, :uuid, primary_key: true)
      add(:title, :string)
      add(:timestamp, :utc_datetime)
      add(:algorithm, :jsonb)
      add(:status, :string)
      add(:result, :jsonb)
      add(:notes, :string)
      add(:schedule_id, references(:schedules, type: :uuid, on_delete: :delete_all), null: true)
      add(:zone_id, references(:zones, type: :uuid, on_delete: :delete_all), null: false)

      timestamps()
    end
  end

  # field(:title, :string)
  # field(:timestamp, :utc_datetime)
  # field(:algorithm, :map)
  # field(:status, :string)
  # field(:result, :map)
  # field(:notes, :string)

  # belongs_to(:schedule, Dripio.Schedule)
  # belongs_to(:zone, Dripio.Zone)

  # timestamps()
end
