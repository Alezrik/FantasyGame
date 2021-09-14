defmodule Platform.ZonesTest do
  use Platform.DataCase

  alias Platform.Zones

  describe "zones" do
    alias Platform.Zones.Zone

    @valid_attrs %{name: "some name"}
    @update_attrs %{name: "some updated name"}
    @invalid_attrs %{name: nil}

    def zone_fixture(attrs \\ %{}) do
      {:ok, zone} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Zones.create_zone()

      zone
    end

    test "list_zones/0 returns all zones" do
      zone = zone_fixture()
      assert Zones.list_zones() == [zone]
    end

    test "get_zone!/1 returns the zone with given id" do
      zone = zone_fixture()
      assert Zones.get_zone!(zone.id) == zone
    end

    test "create_zone/1 with valid data creates a zone" do
      assert {:ok, %Zone{} = zone} = Zones.create_zone(@valid_attrs)
      assert zone.name == "some name"
    end

    test "create_zone/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Zones.create_zone(@invalid_attrs)
    end

    test "update_zone/2 with valid data updates the zone" do
      zone = zone_fixture()
      assert {:ok, %Zone{} = zone} = Zones.update_zone(zone, @update_attrs)
      assert zone.name == "some updated name"
    end

    test "update_zone/2 with invalid data returns error changeset" do
      zone = zone_fixture()
      assert {:error, %Ecto.Changeset{}} = Zones.update_zone(zone, @invalid_attrs)
      assert zone == Zones.get_zone!(zone.id)
    end

    test "delete_zone/1 deletes the zone" do
      zone = zone_fixture()
      assert {:ok, %Zone{}} = Zones.delete_zone(zone)
      assert_raise Ecto.NoResultsError, fn -> Zones.get_zone!(zone.id) end
    end

    test "change_zone/1 returns a zone changeset" do
      zone = zone_fixture()
      assert %Ecto.Changeset{} = Zones.change_zone(zone)
    end
  end
end
