defmodule Confage.ServerTest do
  use ExUnit.Case
  require Poison

  setup_all do
    port = Application.get_env(:tcp_server, :port, 6666)
    ip = Application.get_env(:tcp_server, :ip, {127, 0, 0, 1})
    {:ok, socket} = :gen_tcp.connect(ip, port, [:binary, active: false])
    %{socket: socket}
  end

  test "test send", %{socket: socket} do
    assert :ok = :gen_tcp.send(socket, "test")
    assert {:ok, "wrong command"} = :gen_tcp.recv(socket, 0)
  end

  test "get config", %{socket: socket} do
    Confage.Storage.create_app("name")
    Confage.Storage.set_configs("name", Poison.encode!(%{"key" => "val"}))
    assert :ok = :gen_tcp.send(socket, "get_config:name")
    assert {:ok, data} = :gen_tcp.recv(socket, 0)
    assert {:ok, %{"key" => "val"}} = Poison.decode(data)
    Confage.Storage.del_app("name")
  end

  test "subscribe", %{socket: socket} do
    Confage.Storage.create_app("sub_app")
    Confage.Storage.set_configs("sub_app", Poison.encode!(%{key: "val"}))
    assert :ok = :gen_tcp.send(socket, "subscribe:sub_app")
    assert {:ok, "ok"} = :gen_tcp.recv(socket, 0)
    Confage.Storage.set_configs("sub_app", Poison.encode!(%{key1: "val1"}))
    assert {:ok, _data} = :gen_tcp.recv(socket, 0)
    Confage.Storage.del_app("sub_app")
  end
end
