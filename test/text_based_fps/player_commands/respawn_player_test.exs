defmodule TextBasedFPS.PlayerCommands.RespawnPlayerTest do
  alias TextBasedFPS.CommandExecutor
  alias TextBasedFPS.GameMap.Matrix
  alias TextBasedFPS.Room
  alias TextBasedFPS.RoomPlayer
  alias TextBasedFPS.ServerState

  use ExUnit.Case, async: true

  setup do
    state = ServerState.new() |> ServerState.add_player("foo")
    %{state: state}
  end

  test "requires player to be in a room", %{state: state} do
    assert {:error, _state, error_message} = CommandExecutor.execute(state, "foo", "health")
    assert error_message =~ "You need to be in a room"
  end

  test "respawns player when they're dead", %{state: state} do
    state = state
    |> ServerState.add_room("spaceship", "foo")
    |> ServerState.update_room("spaceship", &(Room.kill_player(&1, "foo")))

    assert {:ok, state, "You're back!"} = CommandExecutor.execute(state, "foo", "respawn")

    room = ServerState.get_room(state, "spaceship")
    assert room.players["foo"].health == RoomPlayer.max_health
    assert room.players["foo"].coordinates != nil
    assert room.players["foo"].direction != nil
    assert room.players["foo"].ammo != {0, 0}
    assert Matrix.player_at?(room.game_map.matrix, room.players["foo"].coordinates, "foo") == true
  end

  test "doesn't respawn player if they're alive", %{state: state} do
    state = state
    |> ServerState.add_room("spaceship", "foo")
    |> ServerState.update_room("spaceship", fn room ->
      Room.update_player(room, "foo", &(Map.put(&1, :health, 90)))
    end)

    assert {:error, state, "You're already alive!"} = CommandExecutor.execute(state, "foo", "respawn")

    room = ServerState.get_room(state, "spaceship")
    assert room.players["foo"].health == 90
  end
end
