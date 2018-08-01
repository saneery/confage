defmodule Confage.StorageTest do
  use ExUnit.Case

  alias Confage.Storage

  test "create table" do
    assert :ok == Storage.create_app("name")
    assert ["name"] == Storage.apps()
    Storage.del_app("name")
  end

  test "set del configs" do
    assert :ok == Storage.create_app("name")
    assert :ok == Storage.set_configs("name", %{"d" => 4})
    assert %{"d" => 4} == Storage.app_configs("name")
    Storage.set_configs("name", "sdf")
    Storage.del_app("name")
  end
end
