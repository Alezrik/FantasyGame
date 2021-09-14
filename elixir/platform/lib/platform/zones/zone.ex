defmodule Platform.Zones.Zone do
  @moduledoc false
  use Ecto.Schema
  import Ecto.Changeset

  schema "zones" do
    field :name, :string
    belongs_to :world, Platform.Worlds.World

    timestamps()
  end

  @doc false
  def changeset(zone, attrs) do
    zone
    |> cast(attrs, [:name])
    |> validate_required([:name])
  end
end
