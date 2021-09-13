defmodule Platform.Session.SessionManager do
  @moduledoc false
  use Supervisor

  def start_link(init_arg) do
    Supervisor.start_link(__MODULE__, init_arg, name: __MODULE__)
  end

  @impl true
  def init(_init_arg) do
    {:ok, _} = Registry.start_link(keys: :unique, name: Registry.Session)
    children = [
      {Platform.Session.SessionWorkerSupervisor, []}
    ]

    Supervisor.init(children, strategy: :one_for_one)
  end
end
