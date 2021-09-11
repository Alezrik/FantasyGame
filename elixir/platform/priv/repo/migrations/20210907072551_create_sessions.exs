defmodule Platform.Repo.Migrations.CreateSessions do
  use Ecto.Migration

  def change do
    create table(:sessions) do
      add :cpu, :string
      add :deviceid, :string
      add :localip, :string
      add :last_access, :utc_datetime

      timestamps()
    end

    create unique_index(:sessions, [:cpu, :deviceid, :localip])
  end
end
