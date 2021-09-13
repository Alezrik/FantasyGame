defmodule PlatformWeb.LoginController do
  use PlatformWeb, :controller

  require Logger

  action_fallback PlatformWeb.FallbackController

  def create(conn, %{"username" => username, "password" => password}) do
    deviceid = get_req_header(conn, "deviceid")
    Logger.info("deviceid: #{deviceid}")
    Logger.info("headers: #{inspect(conn.req_headers)}")

    case Platform.Login.login_user(%{username: username, password: password, deviceid: deviceid}) do
      {:error, reason} ->
        Logger.warn("login failure: #{reason}")
        conn
        |> put_status(400)
        |> render("error.json", %{errors: "Invalid Credentials"})
      {:ok, token} ->
        Logger.info("login authenticate success")
        conn
        |> put_status(:created)
        |> render("login.json", %{token: token})
    end
  end

  def create(conn, options) do
    Logger.error("invalid create session request: missing args")

    conn
    |> put_status(400)
    |> render("error.json", %{errors: "invalid args"})
  end
end
