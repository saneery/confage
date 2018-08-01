defmodule Confage.TCP.Server do
  use GenServer

  def start_link() do
    port = Application.get_env(:tcp_server, :port, 6666)
    ip = Application.get_env(:tcp_server, :ip, {127, 0, 0, 1})
    # GenServer.start_link(__MODULE__, [ip, port], [])
    {:ok, _} = :ranch.start_listener(:tcp, 100, :ranch_tcp, [port: port, ip: ip], Confage.TCP.Handler, [])
  end

  def init([ip, port]) do
    {:ok, listen_socket} = :gen_tcp.listen(port, [:binary, {:packet, 0}, {:active, true}, {:ip, ip}])
    {:ok, socket} = :gen_tcp.accept(listen_socket)
    {:ok, %{socket: socket}}
  end

end
