defmodule TextBasedFPS.PlayerCommands.MoveTest do
  use ExUnit.Case, async: true

  alias TextBasedFPS.{CommandExecutor, GameMap, Room, ServerState}

  @map """
  #####
  #   #
  # N #
  #   #
  #####
  """

  setup do
    state =
      ServerState.new()
      |> ServerState.add_player("foo")
      |> ServerState.update_player("foo", &Map.put(&1, :name, "foo"))
      |> ServerState.add_room("spaceship")
      |> ServerState.update_room(
        "spaceship",
        &Map.put(&1, :game_map, GameMap.Builder.build(@map))
      )
      |> ServerState.join_room!("spaceship", "foo")

    %{state: state}
  end

  defp update_player_direction(state, room_name, player_key, direction) do
    ServerState.update_room(state, room_name, fn room ->
      Room.update_player(room, player_key, &Map.put(&1, :direction, direction))
    end)
  end

  test "requires player to be in a room", %{state: state} do
    state = ServerState.remove_player_from_current_room(state, "foo")
    assert {:error, %ServerState{}, error_message} = CommandExecutor.execute(state, "foo", "move")
    assert error_message =~ "You need to be in a room"
  end

  test "requires player to be alive", %{state: state} do
    state = ServerState.update_room(state, "spaceship", &Room.kill_player(&1, "foo"))

    assert {:error, %ServerState{}, error_message} = CommandExecutor.execute(state, "foo", "move")
    assert error_message =~ "You're dead"
  end

  test "returns error if direction is invalid", %{state: state} do
    assert {:error, %ServerState{}, error_message} =
             CommandExecutor.execute(state, "foo", "move foo")

    assert error_message =~ "Unknown direction"
  end

  test "moves player in the specified direction", %{state: state} do
    assert {:ok, state, nil} = CommandExecutor.execute(state, "foo", "move north")
    assert state.rooms["spaceship"].players["foo"].coordinates == {2, 1}

    assert {:ok, state, nil} = CommandExecutor.execute(state, "foo", "move east")
    assert state.rooms["spaceship"].players["foo"].coordinates == {3, 1}

    assert {:ok, state, nil} = CommandExecutor.execute(state, "foo", "move south")
    assert state.rooms["spaceship"].players["foo"].coordinates == {3, 2}

    assert {:ok, state, nil} = CommandExecutor.execute(state, "foo", "move west")
    assert state.rooms["spaceship"].players["foo"].coordinates == {2, 2}
  end

  test "moves the player in their current direction if direction is not supplied in the command",
       %{state: state} do
    state = update_player_direction(state, "spaceship", "foo", :north)
    assert {:ok, state, nil} = CommandExecutor.execute(state, "foo", "move")
    assert state.rooms["spaceship"].players["foo"].coordinates == {2, 1}

    state = update_player_direction(state, "spaceship", "foo", :east)
    assert {:ok, state, nil} = CommandExecutor.execute(state, "foo", "move")
    assert state.rooms["spaceship"].players["foo"].coordinates == {3, 1}

    state = update_player_direction(state, "spaceship", "foo", :south)
    assert {:ok, state, nil} = CommandExecutor.execute(state, "foo", "move")
    assert state.rooms["spaceship"].players["foo"].coordinates == {3, 2}

    state = update_player_direction(state, "spaceship", "foo", :west)
    assert {:ok, state, nil} = CommandExecutor.execute(state, "foo", "move")
    assert state.rooms["spaceship"].players["foo"].coordinates == {2, 2}
  end

  test "grabs object present at the target position and shows message to user", %{state: state} do
    state = ServerState.update_room(state, "spaceship", &Room.add_random_object(&1, {2, 1}))

    assert {:ok, _state, message} = CommandExecutor.execute(state, "foo", "move north")
    assert message =~ "You found:"
  end

  test "doesn't let player move over a wall", %{state: state} do
    assert {:ok, state, nil} = CommandExecutor.execute(state, "foo", "move east")

    assert {:error, %ServerState{}, error_message} =
             CommandExecutor.execute(state, "foo", "move east")

    assert error_message =~ "You can't go in that direction"
  end

  test "doesn't let player move over another player", %{state: state} do
    state =
      state
      |> ServerState.add_player("bar")
      # make room for "bar" in "spaceship"
      |> ServerState.update_room("spaceship", fn room ->
        update_in(
          room.game_map.respawn_positions,
          &(&1 ++ [%GameMap.RespawnPosition{coordinates: {2, 1}, direction: :south}])
        )
      end)
      |> ServerState.join_room!("spaceship", "bar")

    assert {:error, _state, error_message} = CommandExecutor.execute(state, "foo", "move north")
    assert error_message =~ "You can't go in that direction"

    assert {:error, _state, error_message} = CommandExecutor.execute(state, "bar", "move south")
    assert error_message =~ "You can't go in that direction"

    assert {:ok, _state, nil} = CommandExecutor.execute(state, "foo", "move south")
  end
end
