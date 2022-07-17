defmodule TextBasedFPS.Game.Command.TurnTest do
  use TextBasedFPS.GameCase, async: true

  alias TextBasedFPS.Game.{CommandExecutor, Room}
  alias TextBasedFPS.GameState

  setup do
    create_player("foo")
  end

  test "requires player to be in a room" do
    assert {:error, error_message} = CommandExecutor.execute("foo", "turn east")
    assert error_message =~ "You need to be in a room"
  end

  test "requires player to be alive" do
    join_room("foo", "spaceship")
    GameState.Room.update("spaceship", &Room.kill_player(&1, "foo"))

    assert {:error, error_message} = CommandExecutor.execute("foo", "turn east")
    assert error_message =~ "You're dead"
  end

  test "turns the player when direction is valid" do
    join_room("foo", "spaceship")

    assert {:ok, nil} = CommandExecutor.execute("foo", "turn north")
    room = GameState.Room.get("spaceship")
    assert room.players["foo"].direction == :north

    assert {:ok, nil} = CommandExecutor.execute("foo", "turn south")
    room = GameState.Room.get("spaceship")
    assert room.players["foo"].direction == :south

    assert {:ok, nil} = CommandExecutor.execute("foo", "turn west")
    room = GameState.Room.get("spaceship")
    assert room.players["foo"].direction == :west

    assert {:ok, nil} = CommandExecutor.execute("foo", "turn east")
    room = GameState.Room.get("spaceship")
    assert room.players["foo"].direction == :east

    assert {:ok, nil} = CommandExecutor.execute("foo", "turn around")
    room = GameState.Room.get("spaceship")
    assert room.players["foo"].direction == :west
  end

  test "returns error when direction is invalid" do
    join_room("foo", "spaceship")

    assert {:ok, nil} = CommandExecutor.execute("foo", "turn north")

    assert {:error, error_message} = CommandExecutor.execute("foo", "turn lol")
    assert error_message =~ "Unknown direction"

    room = GameState.Room.get("spaceship")
    assert room.players["foo"].direction == :north
  end
end
