defmodule PlatformWeb.SessionControllerTest do
  use PlatformWeb.ConnCase

  alias Platform.Sessions
  alias Platform.Sessions.Session

  @create_attrs %{
    cpu: "some cpu",
    localip: "192.168.0.1",
    deviceid: "some deviceid"
  }

  @invalid_attrs %{deviceid: nil, localip: nil, other: "other", something: "something"}

  @invalid_ip %{
    cpu: "some cpu",
    localip: "blah",
    deviceid: "some deviceid"
  }

  @blank_attrs %{
    cpu: "",
    localip: "",
    deviceid: ""
  }

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  describe "create session" do
    test "renders session when data is valid", %{conn: conn} do
      conn = post(conn, Routes.session_path(conn, :create), @create_attrs)
      assert json_response(conn, 201)["key"]
    end
  end

  describe "create session error missing fields" do
    test "renders session when data is invalid", %{conn: conn} do
      conn = post(conn, Routes.session_path(conn, :create), @invalid_attrs)
      assert json_response(conn, 400)["errors"]
    end
  end

  describe "create session error invalid ip" do
    test "renders session when data is invalid", %{conn: conn} do
      conn = post(conn, Routes.session_path(conn, :create), @invalid_ip)
      assert json_response(conn, 400)["errors"]
    end
  end

  describe "create session error blank attrs" do
    test "renders session when data is invalid", %{conn: conn} do
      conn = post(conn, Routes.session_path(conn, :create), @blank_attrs)
      assert json_response(conn, 400)["errors"]
    end
  end

  describe "create session removes old sessions" do
    test "render and create new session on dupe", %{conn: conn} do
      conn_with_api_header = build_conn()
      conn = post(conn, Routes.session_path(conn, :create), @create_attrs)
      assert json_response(conn, 201)["key"]
      conn2 = post(conn_with_api_header, Routes.session_path(conn, :create), @create_attrs)
      assert json_response(conn2, 201)["key"]
    end
  end
end
