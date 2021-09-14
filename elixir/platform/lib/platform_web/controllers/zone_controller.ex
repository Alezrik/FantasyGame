defmodule PlatformWeb.ZoneController do
  use PlatformWeb, :controller

  alias Platform.Zones
  alias Platform.Zones.Zone

  action_fallback PlatformWeb.FallbackController

  def index(conn, _params) do
    zones = Zones.list_zones()
    render(conn, "index.json", zones: zones)
  end

  def create(conn, %{"zone" => zone_params}) do
    with {:ok, %Zone{} = zone} <- Zones.create_zone(zone_params) do
      conn
      |> put_status(:created)
      |> put_resp_header("location", Routes.zone_path(conn, :show, zone))
      |> render("show.json", zone: zone)
    end
  end

  def show(conn, %{"id" => id}) do
    zone = Zones.get_zone!(id)
    render(conn, "show.json", zone: zone)
  end

  def update(conn, %{"id" => id, "zone" => zone_params}) do
    zone = Zones.get_zone!(id)

    with {:ok, %Zone{} = zone} <- Zones.update_zone(zone, zone_params) do
      render(conn, "show.json", zone: zone)
    end
  end

  def delete(conn, %{"id" => id}) do
    zone = Zones.get_zone!(id)

    with {:ok, %Zone{}} <- Zones.delete_zone(zone) do
      send_resp(conn, :no_content, "")
    end
  end
end
