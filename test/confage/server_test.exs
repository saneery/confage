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
    Confage.Storage.set_configs("name", %{"key" => "val"})
    assert :ok = :gen_tcp.send(socket, "get_config:name")
    assert {:ok, data} = :gen_tcp.recv(socket, 0)
    assert {:ok, %{"key" => "val"}} = Poison.decode(data)
    Confage.Storage.del_app("name")
  end
end
