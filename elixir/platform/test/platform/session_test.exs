defmodule Platform.SessionTest do
  use Platform.DataCase
  use ExUnitProperties
  alias Platform.Session

  describe("Session Internal API") do
    property("create_session/1") do
      check all(
              cpu <- StreamData.string(:ascii, min_length: 5),
              ip1 <- StreamData.integer(1..255),
              ip2 <- StreamData.integer(0..255),
              ip3 <- StreamData.integer(0..255),
              ip4 <- StreamData.integer(0..255),
              deviceid <- StreamData.string(:ascii, min_length: 5),
              ip5 <- StreamData.integer(1..255),
              ip6 <- StreamData.integer(0..255),
              ip7 <- StreamData.integer(0..255),
              ip8 <- StreamData.integer(0..255)
            ) do
        assert {:ok, _} =
                 Session.create_session(%{
                   cpu: cpu,
                   deviceid: deviceid,
                   localip: "#{ip1}.#{ip2}.#{ip3}.#{ip4}",
                   remoteip: "#{ip5}.#{ip6}.#{ip7}.#{ip8}"
                 })
      end
    end
  end
end
