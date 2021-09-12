defmodule Platform.Session do
  require Logger
  def create_session(%{:cpu=>cpu, :deviceid=> deviceid, :localip=> localip, :remoteip=>remoteip}) do

    session_id = UUID.uuid1()
    session_hash =
      :crypto.hash(:sha256, "#{localip}__#{deviceid}__#{cpu}__#{remoteip}")
      |> Base.encode16()

    Memento.transaction! fn ->
      repeat_hash = Memento.Query.select(Platform.SessionTracker, {:==, :session_hash, session_hash})
      if(Enum.count(repeat_hash) > 1) do
        Enum.map(repeat_hash, fn h ->
          Logger.error("removing duplicate session managers: #{h.name} at #{h.node}")
          Memento.Query.delete_record(h)
          GenServer.stop({String.to_atom(h.name), String.to_atom(h.node)})
        end)
      end
    end
    Logger.info("add session to tracker")
    Platform.SessionTracker.add_session(
    session_id,
    session_hash,
    Atom.to_string(node()),
    "session_#{session_id}"
    )

    Logger.info("Startup Worker")

    Platform.Session.SessionWorkerSupervisor.start_child(%{
      localip: localip,
      cpu: cpu,
      deviceid: deviceid,
      remoteip: remoteip,
      session_hash: session_hash,
      session_id: session_id
    })
    session_hash


  end

end