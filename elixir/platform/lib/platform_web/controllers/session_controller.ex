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

  def create(conn, session_params) do
    case Sessions.create_session(session_params) do
      {:ok, session} ->
        json_string =
          :crypto.hash(:sha256, "#{session.localip}__#{session.deviceid}__#{session.cpu}")
          |> Base.encode16()

        Platform.SessionCache.save_session(session.id, json_string)

        conn
        |> put_status(:created)
        |> render("showkey.json", %{key: json_string})

      {:error, err} ->
        Logger.info(inspect(%{errors: JSON.encode!(err.errors)}))

        conn
        |> put_status(400)
        |> render("error.json", %{errors: JSON.encode!(err.errors)})
    end
  end

  def show(conn, %{"id" => id}) do
    session = Sessions.get_session!(id)
    render(conn, "show.json", session: session)
  end

  def update(conn, %{"id" => id, "session" => session_params}) do
    session = Sessions.get_session!(id)

    with {:ok, %Session{} = session} <- Sessions.update_session(session, session_params) do
      render(conn, "show.json", session: session)
    end
  end

  def delete(conn, %{"id" => id}) do
    session = Sessions.get_session!(id)

    with {:ok, %Session{}} <- Sessions.delete_session(session) do
      send_resp(conn, :no_content, "")
    end
  end
end
