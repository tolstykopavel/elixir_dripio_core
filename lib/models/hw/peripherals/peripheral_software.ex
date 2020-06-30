defmodule Dripio.PeripheralSoftware do
  use Ecto.Schema
  import Ecto.Changeset
  use Dripio.Trace

  schema "software" do
    field :version, :string
    field :description, :string
    field :documentation, :string

    belongs_to :peripheral_model, Dripio.PeripheralModel

    timestamps()
  end

  @doc """
  Builds a changeset based on the `struct` and `params`.
  """
  def change_software(model, params \\ %{}) do
    Trace.wrap do
      model
      |> cast(params, [:version, :description, :documentation, :peripheral_model_id])
      |> validate_required([:version, :peripheral_model_id])
      |> foreign_key_constraint(:peripheral_model_id)
    end
  end
end
