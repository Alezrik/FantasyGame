defmodule PlatformWeb.SessionController do
  use PlatformWeb, :controller

  require Logger

  action_fallback PlatformWeb.FallbackController

  def create(conn, %{"cpu" => cpu, "localip" => localip, "deviceid" => deviceid}) do
    remoteip = List.foldr(Tuple.to_list(conn.remote_ip), "", fn acc, e -> "#{acc}.#{e}" end)
    remoteip = String.slice(remoteip, 0, String.length(remoteip) - 1)
    Logger.info("creating new session for client:#{localip}")

    case Platform.Session.create_session(%{
           cpu: cpu,
           deviceid: deviceid,
           localip: localip,
           remoteip: remoteip
         }) do
      {:ok, json_string} ->
        Logger.info('session create successfully')

        conn
        |> put_status(:created)
        |> render("showkey.json", %{key: json_string})

      {:error, reason} ->
        Logger.error("failed create session with : #{reason}")

        conn
        |> put_status(400)
        |> render("error.json", %{errors: "invalid args"})
    end
  end

  def create(conn, options) do
    Logger.error("invalid create session request: missing args")

    conn
    |> put_status(400)
    |> render("error.json", %{errors: "invalid args"})
  end
end
