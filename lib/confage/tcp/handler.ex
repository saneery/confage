defmodule Confage.TCP.Handler do
  require Logger
  require Poison

  def start_link(ref, socket, transport, opts) do
    pid = spawn_link(__MODULE__, :init, [ref, socket, transport, opts])
    Logger.info("connect #{inspect(socket)}")
    {:ok, pid}
  end

  def init(ref, socket, transport, _opts) do
    :ok = :ranch.accept_ack(ref)

    case transport.peername(socket) do
      {:ok, _peer} -> loop(socket, transport)
      {:error, reason} -> Logger.error("init receive error reason: #{inspect(reason)}")
    end
  end

  def loop(socket, transport) do
    transport.setopts(socket, [active: :once])
    {ok, closed, error} = transport.messages()
    receive do
      {^ok, socket, message} ->
        answer = get_answer(message)
        transport.send(socket, answer)
        loop(socket, transport)
      {^closed, socket} ->
        Logger.info("socket closed: #{inspect(socket)}")
      {^error, socket, reason} ->
        Logger.error("socket: #{inspect(socket)}, closed with error: #{inspect(reason)}")
      message ->
        Logger.debug("message on receive block: #{inspect(message)}")
    end
  end

  defp get_answer(message) do
    case String.split(message, ":") do
      ["get_config", app] ->
        app
        |> Confage.Storage.app_configs()
        |> case do
          {:error, reason} -> %{error: reason}
          data -> data
        end
        |> Poison.encode!
      _ ->
        "wrong command"
    end
  end
end
