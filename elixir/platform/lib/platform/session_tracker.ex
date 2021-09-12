defmodule Platform.SessionTracker do
  use Memento.Table,
    attributes: [:id, :session_id, :session_hash, :node, :name],
    index: [:session_id, :session_hash]

  def add_session(session_id, session_hash, node, name) do
    Memento.transaction! fn ->
      Memento.Query.write(%Platform.SessionTracker{
        session_id: session_id,
        session_hash: session_hash,
        node: node,
        name: name
      })
    end
  end
end