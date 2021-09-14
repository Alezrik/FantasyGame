defmodule Platform.Session do
  @moduledoc """
  Session API
  """
  require Logger

  @spec create_session(%{
          cpu: String.t(),
          deviceid: String.t(),
          localip: String.t(),
          remoteip: String.t()
        }) :: {:error, String.t()} | {:ok, String.t()}
  def create_session(%{
        :cpu => cpu,
        :deviceid => deviceid,
        :localip => localip,
        :remoteip => remoteip
      }) do
    case verify_create_session_params(cpu, deviceid, localip, remoteip) do
      {:error, reason} ->
        {:error, reason}

      {:ok} ->
        session_id = UUID.uuid1()

        session_create_time = DateTime.utc_now()
        session_last_req = DateTime.utc_now()

        session_hash =
          :crypto.hash(:sha256, "#{localip}__#{deviceid}__#{cpu}__#{remoteip}")
          |> Base.encode16()

        GenServer.cast(Platform.Session.SessionTracker, {:delete_session, session_hash})

        Logger.info("Startup SessionWorker: session_#{session_id}")

        Platform.Session.SessionWorkerSupervisor.start_child(%{
          localip: localip,
          cpu: cpu,
          deviceid: deviceid,
          remoteip: remoteip,
          session_hash: session_hash,
          session_id: session_id,
          session_create_time: session_create_time,
          session_last_req: session_last_req
        })

        {:ok, session_hash}
    end
  end

  @spec verify_create_session_params(String.t(), String.t(), String.t(), String.t()) ::
          {:error, String.t()} | {:ok}
  defp verify_create_session_params(cpu, deviceid, localip, remoteip) do
    if String.length(localip) < 1 || String.length(cpu) < 1 || String.length(localip) < 1 ||
         String.length(remoteip) < 1 do
      {:error, "missing argument values"}
    else
      if Iptools.is_ipv4?(localip) == false do
        {:error, "invalid ip"}
      else
        {:ok}
      end
    end
  end
end
