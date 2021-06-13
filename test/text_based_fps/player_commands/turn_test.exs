defmodule TextBasedFPS.PlayerCommands.TurnTest do
  alias TextBasedFPS.CommandExecutor
  alias TextBasedFPS.Room
  alias TextBasedFPS.ServerState

  use ExUnit.Case, async: true

  setup do
    state = ServerState.new() |> ServerState.add_player("foo")
    %{state: state}
  end

  test "requires player to be in a room", %{state: state} do
    assert {:error, _state, error_message} = CommandExecutor.execute(state, "foo", "turn east")
    assert error_message =~ "You need to be in a room"
  end

  test "requires player to be alive", %{state: state} do
    state = state
    |> ServerState.add_room("spaceship", "foo")
    |> ServerState.update_room("spaceship", &(Room.kill_player(&1, "foo")))

    assert {:error, _state, error_message} = CommandExecutor.execute(state, "foo", "turn east")
    assert error_message =~ "You're dead"
  end

  test "turns the player if direction is valid", %{state: state} do
    state = ServerState.add_room(state, "spaceship", "foo")

    assert {:ok, state, nil} = CommandExecutor.execute(state, "foo", "turn north")
    assert state.rooms["spaceship"].players["foo"].direction == :north

    assert {:ok, state, nil} = CommandExecutor.execute(state, "foo", "turn south")
    assert state.rooms["spaceship"].players["foo"].direction == :south

    assert {:ok, state, nil} = CommandExecutor.execute(state, "foo", "turn west")
    assert state.rooms["spaceship"].players["foo"].direction == :west

    assert {:ok, state, nil} = CommandExecutor.execute(state, "foo", "turn east")
    assert state.rooms["spaceship"].players["foo"].direction == :east

    assert {:ok, state, nil} = CommandExecutor.execute(state, "foo", "turn around")
    assert state.rooms["spaceship"].players["foo"].direction == :west
  end

  test "returns error if direction is invalid", %{state: state} do
    state = ServerState.add_room(state, "spaceship", "foo")

    assert {:ok, state, nil} = CommandExecutor.execute(state, "foo", "turn north")
    assert {:error, state, error_message} = CommandExecutor.execute(state, "foo", "turn lol")
    assert state.rooms["spaceship"].players["foo"].direction == :north
    assert error_message =~ "Unknown direction"
  end
end
