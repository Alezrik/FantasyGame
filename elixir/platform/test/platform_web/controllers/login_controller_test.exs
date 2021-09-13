defmodule PlatformWeb.LoginControllerTest do
  use PlatformWeb.ConnCase

  @create_attrs %{
    username: "admin",
    password: "password"
  }

  @invalid_attrs_nil %{
    username: nil,
    password: nil
  }

  setup %{conn: conn} do
    {:ok, _user} =
      Platform.Accounts.create_user(%{
        name: "admin",
        email: "here@there.com",
        password: "password"
      })

    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  describe "create valid login" do
    test "renders login token when data is valid", %{conn: conn} do
      conn =
        conn_with_api_header =
        build_conn()
        |> Plug.Conn.put_req_header("deviceid", "testdeviceid")
        |> post(Routes.login_path(conn, :create), @create_attrs)

      assert json_response(conn, 201)["token"]
    end
  end

  test "deny login token when data is nil", %{conn: conn} do
    conn =
      conn_with_api_header =
      build_conn()
      |> Plug.Conn.put_req_header("deviceid", "testdeviceid")
      |> post(Routes.login_path(conn, :create), @invalid_attrs_nil)

    assert json_response(conn, 400)["errors"]
  end

  test "deny login token when deviceid is nil", %{conn: conn} do
    conn =
      conn_with_api_header =
      build_conn()
      |> post(Routes.login_path(conn, :create), @invalid_attrs_nil)

    assert json_response(conn, 400)["errors"]
  end

  test "deny login token when payload is nil", %{conn: conn} do
    conn =
      conn_with_api_header =
      build_conn()
      |> post(Routes.login_path(conn, :create), %{})

    assert json_response(conn, 400)["errors"]
  end
end
