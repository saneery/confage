defmodule Confage.Storage do
  @moduledoc """
  config storage methods
  """
  require Logger
  @dir Application.get_env(:confage, :storage_folder, "./priv/storage")

  def apps() do
    @dir
    |> File.ls!()
    |> Enum.filter(&String.ends_with?(&1, ".json"))
    |> Enum.map(&String.replace(&1, ".json", ""))
  end

  def app_configs(name) do
    @dir
    |> Path.join("#{name}.json")
    |> File.read!()
  end

  def create_app(name) do
    @dir
    |> Path.join("#{name}.json")
    |> File.touch()
  end

  def set_configs(name, data) do
    case Poison.encode(data) do
      {:ok, _encoded_data} ->
        @dir
        |> Path.join("#{name}.json")
        |> File.write(data)
      {:error, _} ->
        {:error, :invalid}
    end
  end

  def del_app(name) do
    @dir
    |> Path.join("#{name}.json")
    |> File.rm()
  end

  # def init() do
  #   File.mkdir_p!(@dir)
  #   @dir
  #   |> File.ls!()
  #   |> Enum.filter(&!File.dir?(Path.join(@dir, &1)))
  #   |> Enum.filter(&String.ends_with?(&1, "-configs"))
  #   |> Enum.each(fn file ->
  #     path = Path.join(@dir, file)
  #     {:ok, _table} = :dets.open_file(String.to_atom(file), file: String.to_charlist(path))
  #   end)
  # end

  # def tables() do
  #   :dets.all()
  #   |> Enum.filter(&is_atom/1)
  #   |> Enum.map(&Atom.to_string/1)
  #   |> Enum.filter(&String.ends_with?(&1, "-configs"))
  #   |> Enum.map(&String.replace(&1, "-configs", ""))
  # end

  # def table_configs(name) do
  #   try do
  #     name
  #     |> to_atom()
  #     |> :dets.match(:"$1")
  #     |> Enum.reduce(%{}, &to_map/2)
  #   rescue
  #     e ->
  #       Logger.error("Error with table_configs: #{inspect(e)}")
  #       {:error, :internal_error}
  #   end
  # end

  # def create_table(name) do
  #   try do
  #     atom_name = to_atom(name)
  #     path =
  #       @dir
  #       |> Path.join(Atom.to_string(atom_name))
  #       |> String.to_charlist()
  #     :dets.open_file(atom_name, file: path)
  #   rescue
  #     e ->
  #       Logger.error("Error with creating dets table: #{inspect(e)}")
  #       {:error, :internal_error}
  #   end
  # end

  # def set_config(name, key, val) do
  #   try do
  #     :dets.insert(to_atom(name), {key, val})
  #     :dets.sync((to_atom(name)))
  #     :ok
  #   rescue
  #     e ->
  #       Logger.error("Error with set_config: #{inspect(e)}")
  #       {:error, :internal_error}
  #   end
  # end

  # def del_config(table, key) do
  #   try do
  #     :dets.delete(to_atom(table), key)
  #     :dets.sync(to_atom(table))
  #     :ok
  #   rescue
  #     e ->
  #       Logger.error("Error with del_config: #{inspect(e)}")
  #       {:error, :internal_error}
  #   end
  # end

  # def del_table(table) do
  #   try do
  #     atom_name = to_atom(table)
  #     path =
  #       @dir
  #       |> Path.join(Atom.to_string(atom_name))
  #     File.rm!(path)
  #     :ok
  #   rescue
  #     e ->
  #       Logger.error("Error with del_table: #{inspect(e)}")
  #       {:error, :internal_error}
  #   end
  # end

  # defp to_atom(name), do: :"#{name}-configs"

  # defp to_map([{key, data}], acc) when is_list(key) do
  #   keys = Enum.map(key, fn key -> Access.key(key, %{}) end)
  #   put_in(acc, keys, data)
  # end
  # defp to_map([{key, data}], acc), do: put_in(acc, [key], data)

end
