defmodule Dripio.PeripheralType do
  use Ecto.Schema
  import Ecto.Changeset
  use Dripio.Trace

  schema "peripheral_types" do
    field :title, :string
    field :description, :string

    has_many :peripheral_models, Dripio.PeripheralModel

    timestamps()
  end

  @doc """
  Builds a changeset based on the `struct` and `params`.
  """
  def change_peripheral_type(struct, params \\ %{}) do
    Trace.wrap do
      struct
      |> cast(params, [:title, :description])
      |> validate_required([:title])
    end
  end
end
