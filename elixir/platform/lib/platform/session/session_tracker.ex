require Logger

defmodule Platform.Session.SessionTracker do
  @moduledoc false
  use GenServer, restart: :transient

  def init(init_arg) do
    Phoenix.PubSub.subscribe(Platform.PubSub, "create-session", [])
    Phoenix.PubSub.subscribe(Platform.PubSub, "delete-session", [])

    {:ok, init_arg}
  end

  def handle_cast({:add_session, session_hash, node}, state) do
    state = [%{session_hash: session_hash, node: node} | state]
    Logger.info("added to session tracker")
    {:noreply, state}
  end

  def handle_cast({:delete_session, session_hash}, state) do
    new_state = Enum.filter(state, fn f -> f.session_hash != session_hash end)

    if Enum.count(new_state) != Enum.count(state) do
      Logger.info("removed old state from session tracker")
    end

    {:noreply, new_state}
  end

  def handle_call({:get_worker, session_hash}, _from, state) do
    worker = Enum.filter(state, fn obj -> obj.session_hash == session_hash end)
    {:reply, worker, state}
  end

  def start_link(default) do
    {:ok, pid} = GenServer.start_link(__MODULE__, default, name: Platform.Session.SessionTracker)
    {:ok, pid}
  end

  def handle_info(receive, _socket) do
    case(receive.msg) do
      "create-session" ->
        GenServer.cast(__MODULE__, {:add_session, receive.session_hash, receive.node})

      "delete-session" ->
        GenServer.cast(__MODULE__, {:delete_session, receive.session_hash})
    end

    {:noreply, []}
  end
end
