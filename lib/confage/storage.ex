defmodule Confage.Storage do
  @moduledoc """
  Methods for work with json files
  """
  require Logger
  @dir Application.get_env(:confage, :storage_folder, "./priv/storage")

  @doc "Get list of all json files"
  @spec apps() :: list(String.t()) | {:error, atom()}
  def apps() do
    case File.ls(@dir) do
      {:ok, list} ->
        list
        |> Enum.filter(&String.ends_with?(&1, ".json"))
        |> Enum.map(&String.replace(&1, ".json", ""))
      {:error, _reason} = e -> e
    end
  end

  @doc "Read content from file"
  @spec app_configs(name :: String.t()) :: {:ok, String.t()} | {:error, atom()}
  def app_configs(name) do
    @dir
    |> Path.join("#{name}.json")
    |> File.read()
  end

  @doc "Create json file"
  @spec create_app(name :: String.t()) :: :ok | {:error, atom()}
  def create_app(name) do
    unless File.exists?(@dir) do
      File.mkdir_p(@dir)
    end
    @dir
    |> Path.join("#{name}.json")
    |> File.write("{}")
  end

  @doc "Validate and set content to the file"
  @spec set_configs(name :: String.t(), data :: String.t()) :: :ok | {:error, any()}
  def set_configs(name, data) do
    case Poison.encode(data) do
      {:ok, _encoded_data} ->
        @dir
        |> Path.join("#{name}.json")
        |> File.write(data)
        |> case do
          :ok ->
            Confage.TCP.Subscribe.send_subs(name)
            :ok
          {:error, _} = e -> e
        end
      {:error, _} ->
        {:error, :invalid}
    end
  end

  @doc "Delete json file"
  @spec del_app(name :: String.t()) :: :ok | {:error, atom()}
  def del_app(name) do
    @dir
    |> Path.join("#{name}.json")
    |> File.rm()
  end

end
