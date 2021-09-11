defmodule Platform.SessionCache do
  use Memento.Table,
    attributes: [:sessionid, :sessionkey],
    index: [:sessionkey]

  def save_session(sessionid, sessionkey) do
    Memento.transaction!(fn ->
      Memento.Query.write(%Platform.SessionCache{
        sessionid: sessionid,
        sessionkey: sessionkey
      })

      all = Memento.Query.all(Platform.SessionCache)
    end)
  end
end
