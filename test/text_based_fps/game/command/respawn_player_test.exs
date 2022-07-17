defmodule TextBasedFPS.Game.Command.RespawnPlayerTest do
  use TextBasedFPS.GameCase, async: true

  alias TextBasedFPS.Game.{CommandExecutor, Room, RoomPlayer}
  alias TextBasedFPS.{GameMap, GameState}

  setup do
    create_player("foo")
  end

  test "requires player to be in a room" do
    assert {:error, error_message} = CommandExecutor.execute("foo", "move")
    assert error_message =~ "You need to be in a room"
  end

  test "respawns player when they're dead" do
    join_room("foo", "spaceship")
    GameState.update_room("spaceship", &Room.kill_player(&1, "foo"))

    assert {:ok, "You're back!"} = CommandExecutor.execute("foo", "respawn")

    room = GameState.get_room("spaceship")
    assert room.players["foo"].health == RoomPlayer.max_health()
    assert room.players["foo"].coordinates != nil
    assert room.players["foo"].direction != nil
    assert room.players["foo"].ammo != {0, 0}

    assert GameMap.Matrix.player_at?(room.game_map.matrix, room.players["foo"].coordinates, "foo") ==
             true
  end

  test "doesn't respawn player if they're alive" do
    join_room("foo", "spaceship")

    GameState.update_room("spaceship", fn room ->
      Room.update_player(room, "foo", &Map.put(&1, :health, 90))
    end)

    assert {:error, "You're already alive!"} = CommandExecutor.execute("foo", "respawn")

    room = GameState.get_room("spaceship")
    assert room.players["foo"].health == 90
  end
end
