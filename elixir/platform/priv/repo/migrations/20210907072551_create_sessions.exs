defmodule Platform.Repo.Migrations.CreateSessions do
  use Ecto.Migration

  def change do
    create table(:sessions) do
      add :cpu, :string
      add :deviceid, :string
      add :localip, :string

      timestamps()
    end

  end
end
