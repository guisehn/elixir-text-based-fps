defmodule TextBasedFPS.PlayerCommands.AmmoTest do
  alias TextBasedFPS.{CommandExecutor, Room, ServerState}

  use ExUnit.Case, async: true

  setup do
    state = ServerState.new() |> ServerState.add_player("foo")
    %{state: state}
  end

  test "requires player to be in a room", %{state: state} do
    assert {:error, %ServerState{}, error_message} = CommandExecutor.execute(state, "foo", "ammo")
    assert error_message =~ "You need to be in a room"
  end

  test "returns ammo", %{state: state} do
    state =
      state
      |> ServerState.add_room("spaceship", "foo")
      |> ServerState.update_room("spaceship", fn room ->
        Room.update_player(room, "foo", &Map.put(&1, :ammo, {2, 3}))
      end)

    assert {:ok, %ServerState{}, "Ammo: 2/3"} = CommandExecutor.execute(state, "foo", "ammo")
  end
end
