defmodule Platform.Repo.Migrations.ZonesBelongsToWorld do
  use Ecto.Migration

  def change do
    alter table(:zones) do
      add :world_id, references(:worlds)
    end
  end
end
