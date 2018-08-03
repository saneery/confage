defmodule Confage.TCP.Subscribe do
  use GenServer

  def start_link() do
    GenServer.start_link(__MODULE__, :subs, [name: __MODULE__])
  end

  def init(table) do
    pid = :ets.new(table, [:set, :named_table])
    {:ok, pid}
  end

  def subscribe(app, socket, transport) do
    GenServer.cast(__MODULE__, {:subscribe, app, socket, transport})
  end

  def send_subs(app) do
    GenServer.cast(__MODULE__, {:send_subs, app})
  end

  def unsubscribe(socket) do
    GenServer.cast(__MODULE__, {:unsubscribe, socket})
  end

  def handle_cast({:subscribe, app, socket, transport}, ets_pid) do
    :ets.insert(ets_pid, {app, transport, socket})
    {:noreply, ets_pid}
  end

  def handle_cast({:send_subs, app}, ets_pid) do
    case :ets.lookup(ets_pid, app) do
      [{_, transport, socket}] ->
        case Confage.Storage.app_configs(app) do
          {:ok, data} -> transport.send(socket, data)
          {:error, _} = e -> e
        end
      _ ->
        {:error, :no_subs}
    end
    {:noreply, ets_pid}
  end

  def handle_cast({:unsubscribe, socket}, ets_pid) do
    :ets.match_delete(ets_pid, {:"_", :"_", socket})
    {:noreply, ets_pid}
  end
end
