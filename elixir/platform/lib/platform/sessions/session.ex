defmodule Platform.Sessions.Session do
  use Ecto.Schema
  import Ecto.Changeset

  schema "sessions" do
    field :cpu, :string
    field :deviceid, :string
    field :localip, :string

    timestamps()
  end

  @doc false
  def changeset(session, attrs) do
    session
    |> cast(attrs, [:cpu, :deviceid, :localip])
    |> validate_required([:cpu, :deviceid, :localip])
  end
end
