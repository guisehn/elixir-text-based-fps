defmodule TextBasedFPS.Game.Command.ReloadTest do
  use TextBasedFPS.GameCase, async: true

  import TextBasedFPS.Game.RoomPlayer, only: [max_loaded_ammo: 0]

  alias TextBasedFPS.Game.{CommandExecutor, Room}
  alias TextBasedFPS.GameState

  setup do
    create_player("foo")
  end

  test "requires player to be in a room" do
    GameState.update_player("foo", &%{&1 | room: nil})
    assert {:error, error_message} = CommandExecutor.execute("foo", "move")
    assert error_message =~ "You need to be in a room"
  end

  test "requires player to be alive" do
    join_room("foo", "spaceship")
    GameState.update_room("spaceship", &Room.kill_player(&1, "foo"))

    assert {:error, error_message} = CommandExecutor.execute("foo", "turn east")
    assert error_message =~ "You're dead"
  end

  test "reloads the gun" do
    join_room("foo", "spaceship")

    GameState.update_room("spaceship", fn room ->
      Room.update_player(room, "foo", &Map.put(&1, :ammo, {max_loaded_ammo() - 2, 6}))
    end)

    assert {:ok, message} = CommandExecutor.execute("foo", "reload")
    assert message == "You've reloaded. Ammo: #{max_loaded_ammo()}/#{6 - 2}"

    assert GameState.get_room("spaceship").players["foo"].ammo == {max_loaded_ammo(), 6 - 2}
  end

  test "shows 'no ammo' message if there's no ammo to reload" do
    ammo = {max_loaded_ammo() - 3, 0}

    join_room("foo", "spaceship")

    GameState.update_room("spaceship", fn room ->
      Room.update_player(room, "foo", &Map.put(&1, :ammo, ammo))
    end)

    assert {:error, message} = CommandExecutor.execute("foo", "reload")
    assert message == "You're out of ammo"

    assert GameState.get_room("spaceship").players["foo"].ammo == ammo
  end

  test "shows 'gun is full' message if gun is full" do
    ammo = {max_loaded_ammo(), 3}

    join_room("foo", "spaceship")

    GameState.update_room("spaceship", fn room ->
      Room.update_player(room, "foo", &Map.put(&1, :ammo, ammo))
    end)

    assert {:error, message} = CommandExecutor.execute("foo", "reload")
    assert message == "Your gun is full"

    assert GameState.get_room("spaceship").players["foo"].ammo == ammo
  end
end
