defmodule Platform.Login.LoginWorkerSupervisor do
  @moduledoc false
  use DynamicSupervisor
  require Logger

  def start_link(init_arg) do
    DynamicSupervisor.start_link(__MODULE__, init_arg, name: __MODULE__)
  end

  def start_child(save_state) do
    Logger.info("Starting LoginWorker")
    DynamicSupervisor.start_child(__MODULE__, {Platform.Login.LoginWorker, save_state})
  end

  @impl true
  def init(_init_arg) do
    DynamicSupervisor.init(strategy: :one_for_one)
  end
end
