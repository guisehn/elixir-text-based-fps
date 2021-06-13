defmodule TextBasedFPS.RoomPlayerTest do
  alias TextBasedFPS.RoomPlayer

  use ExUnit.Case, async: true

  test "dead?/1" do
    room_player = RoomPlayer.new("foo")
    assert RoomPlayer.dead?(put_in(room_player.health, 0)) == true
    assert RoomPlayer.dead?(put_in(room_player.health, 1)) == false
  end

  test "increment/2" do
    room_player = RoomPlayer.new("foo") |> Map.put(:kills, 5)
    updated_room_player = RoomPlayer.increment(room_player, :kills)
    assert updated_room_player.kills == 6
  end

  describe "decrement/2" do
    test "ammo" do
      room_player = RoomPlayer.new("foo") |> Map.put(:ammo, {8, 24})
      updated_room_player = RoomPlayer.decrement(room_player, :ammo)
      assert updated_room_player.ammo == {7, 24}
    end

    test "other fields" do
      room_player = RoomPlayer.new("foo") |> Map.put(:health, 100)
      updated_room_player = RoomPlayer.decrement(room_player, :health)
      assert updated_room_player.health == 99
    end
  end

  test "heal/2" do
    room_player = RoomPlayer.new("foo") |> Map.put(:health, 90)

    healed_room_player = RoomPlayer.heal(room_player, 5)
    assert healed_room_player.health == 95

    healed_room_player = RoomPlayer.heal(room_player, 20)
    assert healed_room_player.health == 100
  end

  describe "reload_gun/1" do
    test "success" do
      room_player = RoomPlayer.new("foo") |> Map.put(:ammo, {2, 3})
      assert {:reloaded, updated_room_player} = RoomPlayer.reload_gun(room_player)
      assert updated_room_player.ammo == {5, 0}
    end

    test "already full" do
      room_player = RoomPlayer.new("foo") |> Map.put(:ammo, {RoomPlayer.max_loaded_ammo(), 10})
      assert {:full, updated_room_player} = RoomPlayer.reload_gun(room_player)
      assert updated_room_player.ammo == {RoomPlayer.max_loaded_ammo(), 10}
    end

    test "no ammo" do
      room_player = RoomPlayer.new("foo") |> Map.put(:ammo, {2, 0})
      assert {:no_ammo, updated_room_player} = RoomPlayer.reload_gun(room_player)
      assert updated_room_player.ammo == {2, 0}
    end
  end

  test "display_ammo/1" do
    room_player = RoomPlayer.new("foo") |> Map.put(:ammo, {2, 3})
    assert RoomPlayer.display_ammo(room_player) == "2/3"
  end

  test "max_health/0" do
    assert is_integer(RoomPlayer.max_health())
    assert RoomPlayer.max_health() > 0
  end

  test "max_loaded_ammo/0" do
    assert is_integer(RoomPlayer.max_loaded_ammo())
  end

  test "max_unloaded_ammo/0" do
    assert is_integer(RoomPlayer.max_unloaded_ammo())
  end
end
