defmodule Dripio.Repo.Migrations.CreateUsers do
  use Ecto.Migration

  def change do
    create table(:users, primary_key: false) do
      add :id, :uuid, primary_key: true
      add :email, :string, null: false
      add :fname, :string
      add :lname, :string
      add :avatar, :text
      add :phone, :string
      add :notes, :string
      add :is_confirmed, :boolean, default: false
      add :perms, {:array, :string}
      add :password_hash, :string
      add :security_token, :string
      add :confirmation_token, :string

      timestamps()
    end

    create unique_index(:users, [:email])
  end
end
