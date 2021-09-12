require Logger

defmodule Platform.Session.SessionWorker do
  @moduledoc false
  use GenServer, restart: :transient

  def init(init_arg) do
    {:ok, init_arg}
  end

  def start_link(default) do
    Logger.info("Starting new worker")

    GenServer.start_link(__MODULE__, default,
      name: String.to_atom("session_#{default.session_id}")
    )
  end
end
