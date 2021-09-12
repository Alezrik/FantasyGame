defmodule Platform.SessionTracker do
  @moduledoc false
  use Memento.Table,
    attributes: [:session_id, :session_hash, :node, :name],
    index: [:session_hash]

  def add_session(session_id, session_hash, node, name) do
    Memento.transaction!(fn ->
      Memento.Query.write(%Platform.SessionTracker{
        session_id: session_id,
        session_hash: session_hash,
        node: node,
        name: name
      })
    end)
  end

  def get_sessions_by_hash(session_hash) do
    Memento.transaction!(fn ->
      Memento.Query.select(Platform.SessionTracker, {:==, :session_hash, session_hash})
    end)
  end

  def delete_session_record(session_record) do
    Memento.transaction!(fn ->
      Memento.Query.delete_record(session_record)
    end)
  end
end
