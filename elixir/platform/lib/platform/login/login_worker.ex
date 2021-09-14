require Logger

defmodule Platform.Login.LoginWorker do
  @moduledoc false
  use GenServer, restart: :transient

  def init(init_arg) do
    {:ok, init_arg}
  end

  def start_link(default) do
    Logger.info("Starting new Login worker: login_#{default.login_id}}")


    {:ok, pid} =
      GenServer.start_link(__MODULE__, default, name: String.to_atom("login_#{default.login_id}"))
    Phoenix.PubSub.broadcast(Platform.PubSub, "create-login", %{
      msg: "create-login",
      login_hash: default.login_hash,
      jwt: default.jwt,
      deviceid: default.deviceid,
      node: pid
    })
    {:ok, pid}
  end
  def terminate(_reason, state) do
    Phoenix.PubSub.broadcast(Platform.PubSub, "delete-login", %{
      msg: "delete-login",
      login_hash: state.login_hash
    })
  end
end
