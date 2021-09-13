defmodule PlatformWeb.SessionView do
  use PlatformWeb, :view
  alias PlatformWeb.SessionView

  def render("showkey.json", %{key: key}) do
    %{key: key}
  end

  def render("error.json", %{errors: error}) do
    %{errors: error}
  end
end
