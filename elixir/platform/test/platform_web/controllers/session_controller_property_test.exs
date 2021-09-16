defmodule PlatformWeb.SessionControllerPropertyTest do
  use PlatformWeb.ConnCase

  use ExUnitProperties

  describe "create session with properties" do
    property "post create session", %{conn: conn} do
      check all(
              cpu <- StreamData.string(:ascii, min_length: 5),
              ip1 <- StreamData.integer(1..255),
              ip2 <- StreamData.integer(0..255),
              ip3 <- StreamData.integer(0..255),
              ip4 <- StreamData.integer(0..255),
              deviceid <- StreamData.string(:ascii, min_length: 5)
            ) do
        conn =
          post(conn, Routes.session_path(conn, :create), %{
            cpu: cpu,
            localip: "#{ip1}.#{ip2}.#{ip3}.#{ip4}",
            deviceid: deviceid
          })

        assert json_response(conn, 201)["key"]
      end
    end
  end
end
