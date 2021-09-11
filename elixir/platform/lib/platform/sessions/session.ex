defmodule Platform.Sessions.Session do
  use Ecto.Schema
  import Ecto.Changeset

  schema "sessions" do
    field :cpu, :string
    field :deviceid, :string
    field :localip, :string
    field :last_access, :utc_datetime

    timestamps()
  end

  @doc false
  def changeset(session, attrs) do
    session
    |> cast(attrs, [:cpu, :deviceid, :localip])
    |> validate_required([:cpu, :deviceid, :localip])
    |> unique_constraint([:cpu, :deviceid, :localip])
    |> put_change(:last_access, DateTime.truncate(DateTime.utc_now(), :second))
  end
end
