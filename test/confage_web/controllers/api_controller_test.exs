defmodule Confage.ApiControllerTest do
  use ConfageWeb.ConnCase
  require Poison

  setup_all do
    conn = Phoenix.ConnTest.build_conn() |> using_basic_auth()
    conn = post(conn, "/api/apps/create", %{name: "test_app"})
    assert json_response(conn, 200) == %{"status" => "ok"}
    on_exit fn ->
      conn =
        conn
        |> recycle()
        |> using_basic_auth()
        |> delete("/api/apps/test_app")
      assert json_response(conn, 200) == %{"status" => "ok"}
    end
    {:ok, %{conn: conn}}
  end

  test "create app", %{conn: conn} do
    conn =
      conn
      |> using_basic_auth()
      |> get("/api/apps")
    assert json_response(conn, 200) == %{"data" => ["test_app"], "status" => "ok"}
  end

  test "create config", %{conn: conn} do
    conn =
      conn
      |> using_basic_auth()
      |> post("/api/apps/test_app/config", %{data: Poison.encode!(%{port: 3456, host: "localhost"})})
    assert json_response(conn, 200) == %{"status" => "ok"}
    conn =
      conn
      |> recycle()
      |> using_basic_auth()
      |> get("/api/apps/test_app/config")
    assert json_response(conn, 200) == %{"status" => "ok", "data" => Poison.encode!(%{"port" => 3456, "host" => "localhost"})}
  end

  defp using_basic_auth(conn) do
    username = Application.get_env(:confage, :auth)[:username]
    password = Application.get_env(:confage, :auth)[:password]
    header_content = "Basic " <> Base.encode64("#{username}:#{password}")
    conn |> put_req_header("authorization", header_content)
  end
end
