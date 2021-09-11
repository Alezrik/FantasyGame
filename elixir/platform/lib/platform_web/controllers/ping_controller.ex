defmodule PlatformWeb.PingController do
  use PlatformWeb, :controller

  def index(conn, _params) do
    # render(conn, "index.html")
    json(conn, %{status: "pong"})
  end
end
