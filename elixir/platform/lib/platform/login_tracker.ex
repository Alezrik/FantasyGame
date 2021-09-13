defmodule Platform.LoginTracker do
  @moduledoc false
  use Memento.Table,
    attributes: [:login_id, :login_hash, :deviceid, :token, :node, :name]

  def add_login(login_id, login_hash, deviceid, token, node, name) do
    Memento.transaction!(fn ->
      Memento.Query.write(%Platform.LoginTracker{
        login_id: login_id,
        login_hash: login_hash,
        deviceid: deviceid,
        token: token,
        node: node,
        name: name
      })
    end)
  end
end
