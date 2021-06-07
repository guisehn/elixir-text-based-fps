defmodule TextBasedFPS.GameMap.ObjectsTest do
  alias TextBasedFPS.GameMap.Objects

  use ExUnit.Case, async: true

  test "all/0" do
    assert length(Objects.all()) > 0
  end

  test "object?/1" do
    assert Objects.object?(Objects.AmmoPack.new()) == true
    assert Objects.object?(Objects.HealthPack.new()) == true
    assert Objects.object?(Objects.Player.new("foo")) == true
    assert Objects.object?(:" ") == false
    assert Objects.object?(nil) == false
  end
end
