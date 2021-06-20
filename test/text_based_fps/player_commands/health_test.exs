defmodule TextBasedFPS.PlayerCommands.HealthTest do
  use ExUnit.Case, async: true

  alias TextBasedFPS.{CommandExecutor, Room, ServerState}

  setup do
    state = ServerState.new() |> ServerState.add_player("foo")
    %{state: state}
  end

  test "requires player to be in a room", %{state: state} do
    assert {:error, %ServerState{}, error_message} =
             CommandExecutor.execute(state, "foo", "health")

    assert error_message =~ "You need to be in a room"
  end

  test "returns health", %{state: state} do
    state =
      state
      |> ServerState.add_room("spaceship", "foo")
      |> ServerState.update_room("spaceship", fn room ->
        Room.update_player(room, "foo", &Map.put(&1, :health, 50))
      end)

    assert {:ok, %ServerState{}, "Health: 50%"} = CommandExecutor.execute(state, "foo", "health")
  end

  test "works when player is dead", %{state: state} do
    state =
      state
      |> ServerState.add_room("spaceship", "foo")
      |> ServerState.update_room("spaceship", &Room.kill_player(&1, "foo"))

    assert {:ok, %ServerState{}, "Health: 0%"} = CommandExecutor.execute(state, "foo", "health")
  end
end
