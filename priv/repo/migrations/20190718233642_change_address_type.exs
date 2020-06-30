defmodule Dripio.Repo.Migrations.ChangeAddressType do
  use Ecto.Migration

  def up do
    execute("ALTER TABLE locations ALTER COLUMN address TYPE JSONB USING address::jsonb;")
  end
end
