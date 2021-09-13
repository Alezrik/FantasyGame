require Logger

defmodule Platform.Login.LoginWorker do
  @moduledoc false
  use GenServer, restart: :transient

  def init(init_arg) do
    {:ok, init_arg}
  end

  def start_link(default) do
    Logger.info("Starting new Login worker")
    GenServer.start_link(__MODULE__, default, {:via, Registry, {Registry.Login, "session_#{default.session_id}"}})
  end
end
