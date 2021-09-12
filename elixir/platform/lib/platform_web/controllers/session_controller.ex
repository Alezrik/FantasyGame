defmodule PlatformWeb.SessionController do
  use PlatformWeb, :controller

  alias Platform.Sessions
  alias Platform.Sessions.Session
  require Logger

  action_fallback PlatformWeb.FallbackController

  def index(conn, _params) do
    sessions = Sessions.list_sessions()
    render(conn, "index.json", sessions: sessions)
  end

  def create(conn, %{"cpu"=>cpu, "localip"=> localip, "deviceid"=> deviceid}) do
    remoteip = List.foldr(Tuple.to_list(conn.remote_ip), "", fn acc, e -> "#{acc}.#{e}" end)

    Logger.info("creating new session for client")
    json_string = Platform.Session.create_session(%{
      cpu: cpu,
      deviceid: deviceid,
      localip: localip,
      remoteip: remoteip
    })
    conn
    |> put_status(:created)
    |> render("showkey.json", %{key: json_string})

    #    case Sessions.create_session(session_params) do
#      {:ok, session} ->
#
#        Platform.SessionCache.save_session(session.id, json_string)
#
#
#      {:error, err} ->
#        Logger.info(inspect(%{errors: JSON.encode!(err.errors)}))
#
#        conn
#        |> put_status(400)
#        |> render("error.json", %{errors: JSON.encode!(err.errors)})
#    end

  end
end
