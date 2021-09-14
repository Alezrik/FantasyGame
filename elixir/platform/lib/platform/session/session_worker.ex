require Logger

defmodule Platform.Session.SessionWorker do
  @moduledoc false
  use GenServer, restart: :transient

  def init(init_arg) do
    {:ok, init_arg}
  end

  def start_link(default) do
    Logger.info("Starting new Session worker: session_#{default.session_id}")

    {:ok, pid} = GenServer.start_link(__MODULE__, default)

    Phoenix.PubSub.broadcast(Platform.PubSub, "create-session", %{
      msg: "create-session",
      session_hash: default.session_hash,
      node: pid
    })

    {:ok, pid}
  end

  def terminate(_reason, state) do
    Phoenix.PubSub.broadcast(Platform.PubSub, "delete-session", %{
      msg: "delete-session",
      session_hash: state.session_hash
    })
  end
end
