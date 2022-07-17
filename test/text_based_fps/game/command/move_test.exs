defmodule TextBasedFPS.Game.Command.MoveTest do
  use TextBasedFPS.GameCase, async: true

  alias TextBasedFPS.Game.{CommandExecutor, Room}
  alias TextBasedFPS.GameMap.RespawnPosition
  alias TextBasedFPS.GameState

  @room_map """
  #####
  #   #
  # N #
  #   #
  #####
  """

  setup do
    create_player("foo")
    create_room("spaceship", @room_map)
    join_room("foo", "spaceship")
  end

  defp update_player_direction(room_name, player_key, direction) do
    GameState.update_room(room_name, fn room ->
      Room.update_player(room, player_key, &%{&1 | direction: direction})
    end)
  end

  test "requires player to be in a room" do
    GameState.update_player("foo", &%{&1 | room: nil})
    assert {:error, error_message} = CommandExecutor.execute("foo", "move")
    assert error_message =~ "You need to be in a room"
  end

  test "requires player to be alive" do
    GameState.update_room("spaceship", &Room.kill_player(&1, "foo"))

    assert {:error, error_message} = CommandExecutor.execute("foo", "turn east")
    assert error_message =~ "You're dead"
  end

  test "returns error when direction is invalid" do
    assert {:error, error_message} = CommandExecutor.execute("foo", "move foo")
    assert error_message =~ "Unknown direction"
  end

  test "moves player in the specified direction" do
    assert {:ok, nil} = CommandExecutor.execute("foo", "move north")
    assert GameState.get_room("spaceship").players["foo"].coordinates == {2, 1}

    assert {:ok, nil} = CommandExecutor.execute("foo", "move east")
    assert GameState.get_room("spaceship").players["foo"].coordinates == {3, 1}

    assert {:ok, nil} = CommandExecutor.execute("foo", "move south")
    assert GameState.get_room("spaceship").players["foo"].coordinates == {3, 2}

    assert {:ok, nil} = CommandExecutor.execute("foo", "move west")
    assert GameState.get_room("spaceship").players["foo"].coordinates == {2, 2}
  end

  test "moves the player in their current direction if direction is not supplied in the command" do
    update_player_direction("spaceship", "foo", :north)
    assert {:ok, nil} = CommandExecutor.execute("foo", "move")
    assert GameState.get_room("spaceship").players["foo"].coordinates == {2, 1}

    update_player_direction("spaceship", "foo", :east)
    assert {:ok, nil} = CommandExecutor.execute("foo", "move")
    assert GameState.get_room("spaceship").players["foo"].coordinates == {3, 1}

    update_player_direction("spaceship", "foo", :south)
    assert {:ok, nil} = CommandExecutor.execute("foo", "move")
    assert GameState.get_room("spaceship").players["foo"].coordinates == {3, 2}

    update_player_direction("spaceship", "foo", :west)
    assert {:ok, nil} = CommandExecutor.execute("foo", "move")
    assert GameState.get_room("spaceship").players["foo"].coordinates == {2, 2}
  end

  test "grabs object present at the target position and shows message to user" do
    GameState.update_room("spaceship", &Room.add_random_object(&1, {2, 1}))

    assert {:ok, message} = CommandExecutor.execute("foo", "move north")
    assert message =~ "You found:"
  end

  test "doesn't let player move over a wall" do
    assert {:ok, nil} = CommandExecutor.execute("foo", "move east")
    assert {:error, error_message} = CommandExecutor.execute("foo", "move east")
    assert error_message =~ "You can't go in that direction"
  end

  test "doesn't let player move over another player" do
    # Make room for "bar" in "spaceship"
    GameState.update_room("spaceship", fn room ->
      update_in(
        room.game_map.respawn_positions,
        &(&1 ++ [%RespawnPosition{coordinates: {2, 1}, direction: :south}])
      )
    end)

    create_player("bar")
    join_room("bar", "spaceship")

    assert {:error, error_message} = CommandExecutor.execute("foo", "move north")
    assert error_message =~ "You can't go in that direction"

    assert {:error, error_message} = CommandExecutor.execute("bar", "move south")
    assert error_message =~ "You can't go in that direction"

    assert {:ok, nil} = CommandExecutor.execute("foo", "move south")
  end
end
