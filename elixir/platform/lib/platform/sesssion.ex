defmodule Platform.Session do
  @moduledoc false
  require Logger

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

        session_hash =
          :crypto.hash(:sha256, "#{localip}__#{deviceid}__#{cpu}__#{remoteip}")
          |> Base.encode16()

        repeat_hash = Platform.SessionTracker.get_sessions_by_hash(session_hash)

        {:ok} = remove_old_sessions(repeat_hash)

        Logger.info("add session to tracker")

        Platform.SessionTracker.add_session(
          session_id,
          session_hash,
          Atom.to_string(node()),
          "session_#{session_id}"
        )

        Logger.info("Startup SessionWorker: session_#{session_id}")

        Platform.Session.SessionWorkerSupervisor.start_child(%{
          localip: localip,
          cpu: cpu,
          deviceid: deviceid,
          remoteip: remoteip,
          session_hash: session_hash,
          session_id: session_id
        })

        {:ok, session_hash}
    end
  end

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

  defp remove_old_sessions(dup_hash) when is_list(dup_hash) and length(dup_hash) > 0 do
    Enum.each(dup_hash, fn h ->
      remove_session(h)
    end)

    {:ok}
  end

  defp remove_old_sessions(dup_hash) when is_list(dup_hash) do
    {:ok}
  end

  defp remove_old_sessions(dup_hash) when is_struct(dup_hash) do
    remove_session(dup_hash)
    {:ok}
  end

  defp remove_session(session) do
    Logger.warn("removing duplicate session workers: #{session.name} at #{session.node}")
    Platform.SessionTracker.delete_session_record(session)
    GenServer.stop({String.to_atom(session.name), String.to_atom(session.node)})
    {:ok}
  end
end
