defmodule Dripio.PeripheralModel do
  use Ecto.Schema
  import Ecto.Changeset
  use Dripio.Trace

  schema "peripheral_models" do
    field :title, :string
    field :description, :string
    field :schematics, :string
    field :documentation, :string
    field :metadata_schema, :string

    belongs_to :peripheral_type, Dripio.PeripheralType

    timestamps()
  end

  @doc """
  Builds a changeset based on the `struct` and `params`.
  """
  def change_peripheral_model(struct, params \\ %{}) do
    Trace.wrap do
      struct
      |> cast(params, [:title, :description, :peripheral_type_id, :schematics, :documentation, :metadata_schema])
      |> validate_required([:title, :peripheral_type_id])
      |> foreign_key_constraint(:peripheral_type_id)
    end
  end
end
