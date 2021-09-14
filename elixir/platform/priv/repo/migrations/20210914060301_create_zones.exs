defmodule Platform.Repo.Migrations.CreateZones do
  use Ecto.Migration

  def change do
    create table(:zones) do
      add :name, :string

      timestamps()
    end

  end
end
