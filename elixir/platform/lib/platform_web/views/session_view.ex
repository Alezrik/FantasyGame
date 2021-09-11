defmodule PlatformWeb.SessionView do
  use PlatformWeb, :view
  alias PlatformWeb.SessionView

  def render("index.json", %{sessions: sessions}) do
    %{data: render_many(sessions, SessionView, "session.json")}
  end

  def render("show.json", %{session: session}) do
    %{data: render_one(session, SessionView, "session.json")}
  end

  def render("session.json", %{session: session}) do
    %{id: session.id, cpu: session.cpu, deviceid: session.deviceid, localip: session.localip}
  end

  def render("showkey.json", %{key: key}) do
    %{key: key}
  end

  def render("error.json", %{errors: error}) do
    %{errors: error}
  end
end
