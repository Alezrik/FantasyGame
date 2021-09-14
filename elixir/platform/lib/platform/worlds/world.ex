defmodule Platform.Worlds.World do
  @moduledoc false
  use Ecto.Schema
  import Ecto.Changeset

  schema "worlds" do
    field :name, :string
    has_many :zones, Platform.Zones.Zone

    timestamps()
  end

  @doc false
  def changeset(world, attrs) do
    world
    |> cast(attrs, [:name])
    |> validate_required([:name])
  end
end
