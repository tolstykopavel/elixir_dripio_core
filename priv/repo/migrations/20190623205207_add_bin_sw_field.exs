defmodule Dripio.Repo.Migrations.AddBinSwField do
  use Ecto.Migration

  def change do
    alter table(:device_software) do
      add(:bin, :bytea)
    end
  end
end
