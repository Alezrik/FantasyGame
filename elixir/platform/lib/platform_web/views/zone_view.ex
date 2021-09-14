defmodule PlatformWeb.ZoneView do
  use PlatformWeb, :view
  alias PlatformWeb.ZoneView

  def render("index.json", %{zones: zones}) do
    %{data: render_many(zones, ZoneView, "zone.json")}
  end

  def render("show.json", %{zone: zone}) do
    %{data: render_one(zone, ZoneView, "zone.json")}
  end

  def render("zone.json", %{zone: zone}) do
    %{id: zone.id,
      name: zone.name}
  end
end
