defmodule ConfageWeb.ApiController do
  use ConfageWeb, :controller
  alias Confage.Storage

  def app_list(conn, _) do
    list = Storage.apps()
    json(conn, %{status: :ok, data: list})
  end

  def app_config(conn, %{"name" => name}) do
    case Storage.app_configs(name) do
      {:error, reason} ->
        json(conn, %{status: :error, reason: reason})
      {:ok, data} -> json(conn, %{status: :ok, data: data})
    end
  end

  def create_app(conn, %{"name" => name}) do
    case Storage.create_app(name) do
      :ok ->
        json(conn, %{status: :ok})
      {:error, reason} ->
        json(conn, %{status: :error, reason: reason})
    end
  end

  def delete_app(conn, %{"name" => name}) do
    case Storage.del_app(name) do
      :ok -> json(conn, %{status: :ok})
      {:error, reason} ->
        json(conn, %{status: :error, reason: reason})
    end
  end

  def set_config(conn, %{"name" => name, "data" => data}) do
    case Storage.set_configs(name, data) do
      {:error, reason} -> json(conn, %{status: :error, reason: reason})
      _ -> json(conn, %{status: :ok})
    end
  end

end
