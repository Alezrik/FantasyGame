require Logger

defmodule Platform.Login.LoginTracker do
  @moduledoc false
  use GenServer, restart: :transient

  def init(init_arg) do
    Phoenix.PubSub.subscribe(Platform.PubSub, "create-login", [])
    Phoenix.PubSub.subscribe(Platform.PubSub, "delete-login", [])
    Phoenix.PubSub.subscribe(Platform.PubSub, "delete-session", [])

    {:ok, init_arg}
  end

  def handle_cast({:add_login, login_hash, jwt, node}, state) do
    state = [%{login_hash: login_hash, jwt: jwt, node: node} | state]
    Logger.info("added to login tracker")
    {:noreply, state}
  end

  def handle_cast({:delete_login, login_hash}, state) do
    new_state = Enum.filter(state, fn f -> f.login_hash != login_hash end)

    if Enum.count(new_state) != Enum.count(state) do
      Logger.info("removed old state from login tracker")
    end

    {:noreply, new_state}
  end

  def handle_cast({:delete_session, deviceid}, state) do
    Enum.each(state, fn s ->
      if s.deviceid == deviceid do
        GenServer.stop(s.pid)
      end
    end)

    new_state = Enum.filter(state, fn f -> f.deviceid != deviceid end)

    if Enum.count(new_state) != Enum.count(state) do
      Logger.info("removed old state from login tracker")
    end

    {:noreply, new_state}
  end

  def handle_call({:get_worker, login_hash}, _from, state) do
    worker = Enum.filter(state, fn obj -> obj.login_hash == login_hash end)
    {:reply, worker, state}
  end

  def start_link(default) do
    {:ok, pid} = GenServer.start_link(__MODULE__, default, name: Platform.Login.LoginTracker)
    {:ok, pid}
  end

  def handle_info(receive, _socket) do
    case(receive.msg) do
      "create-login" ->
        GenServer.cast(__MODULE__, {:add_login, receive.login_hash, receive.jwt, receive.node})

      "delete-login" ->
        GenServer.cast(__MODULE__, {:delete_login, receive.session_hash})

      "delete-session" ->
        GenServer.cast(__MODULE__, {:delete_session, receive.session_hash})
    end

    {:noreply, []}
  end
end
