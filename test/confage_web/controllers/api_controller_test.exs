defmodule Confage.ApiControllerTest do
  use ConfageWeb.ConnCase
  require Poison

  setup_all do
    conn = Phoenix.ConnTest.build_conn()
    conn = post(conn, "/api/apps/create", %{name: "test_app"})
    assert json_response(conn, 200) == %{"status" => "ok"}
    on_exit fn ->
      conn = delete(conn, "/api/apps/test_app")
      assert json_response(conn, 200) == %{"status" => "ok"}
    end
    {:ok, %{conn: conn}}
  end

  test "create app", %{conn: conn} do
    conn = get(conn, "/api/apps")
    assert json_response(conn, 200) == %{"data" => ["test_app"], "status" => "ok"}
  end

  test "create config", %{conn: conn} do
    conn = post(conn, "/api/apps/test_app/config", %{data: Poison.encode!(%{port: 3456, host: "localhost"})})
    assert json_response(conn, 200) == %{"status" => "ok"}
    conn = get(conn, "/api/apps/test_app/config")
    assert json_response(conn, 200) == %{"status" => "ok", "data" => Poison.encode!(%{"port" => 3456, "host" => "localhost"})}
  end
end
