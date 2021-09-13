defmodule PlatformWeb.LoginView do
  use PlatformWeb, :view
  alias PlatformWeb.LoginView

  def render("login.json", %{token: token}) do
    %{token: token}
  end

  def render("error.json", %{errors: error}) do
    %{errors: error}
  end
end
