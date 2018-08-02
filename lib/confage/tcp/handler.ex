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
        answer = handle(message, socket, transport)
        if answer, do: transport.send(socket, answer)
        loop(socket, transport)
      {^closed, socket} ->
        Logger.info("socket closed: #{inspect(socket)}")
      {^error, socket, reason} ->
        Logger.error("socket: #{inspect(socket)}, closed with error: #{inspect(reason)}")
      message ->
        Logger.debug("message on receive block: #{inspect(message)}")
    end
    Confage.TCP.Subscribe.unsubscribe(socket)
  end

  defp handle(message, socket, transport) do
    message
    |> String.trim()
    |> String.split(":")
    |> case do
      ["get_config", app] ->
        app
        |> Confage.Storage.app_configs()
        |> case do
          {:error, :enoent} -> "not_found"
          {:ok, data} -> data
        end
      ["subscribe", app] ->
        Confage.TCP.Subscribe.subscribe(app, socket, transport)
        false
      _ ->
        "wrong command"
    end
  end
end
