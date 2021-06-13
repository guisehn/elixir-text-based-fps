defmodule TextBasedFPS.PlayerCommands.ReloadTest do
  alias TextBasedFPS.CommandExecutor
  alias TextBasedFPS.Room
  alias TextBasedFPS.ServerState

  import TextBasedFPS.RoomPlayer, only: [max_loaded_ammo: 0]

  use ExUnit.Case, async: true

  setup do
    state = ServerState.new() |> ServerState.add_player("foo")
    %{state: state}
  end

  test "requires player to be in a room", %{state: state} do
    assert {:error, %ServerState{}, error_message} =
             CommandExecutor.execute(state, "foo", "reload")

    assert error_message =~ "You need to be in a room"
  end

  test "requires player to be alive", %{state: state} do
    state =
      state
      |> ServerState.add_room("spaceship", "foo")
      |> ServerState.update_room("spaceship", &Room.kill_player(&1, "foo"))

    assert {:error, %ServerState{}, error_message} =
             CommandExecutor.execute(state, "foo", "reload")

    assert error_message =~ "You're dead"
  end

  test "reloads the gun", %{state: state} do
    state =
      state
      |> ServerState.add_room("spaceship", "foo")
      |> ServerState.update_room("spaceship", fn room ->
        Room.update_player(room, "foo", &Map.put(&1, :ammo, {max_loaded_ammo() - 2, 6}))
      end)

    assert {:ok, state, message} = CommandExecutor.execute(state, "foo", "reload")
    assert message == "You've reloaded. Ammo: #{max_loaded_ammo()}/#{6 - 2}"
    assert state.rooms["spaceship"].players["foo"].ammo == {max_loaded_ammo(), 6 - 2}
  end

  test "shows 'no ammo' message if there's no ammo to reload", %{state: state} do
    ammo = {max_loaded_ammo() - 3, 0}

    state =
      state
      |> ServerState.add_room("spaceship", "foo")
      |> ServerState.update_room("spaceship", fn room ->
        Room.update_player(room, "foo", &Map.put(&1, :ammo, ammo))
      end)

    assert {:error, state, message} = CommandExecutor.execute(state, "foo", "reload")
    assert message == "You're out of ammo"
    assert state.rooms["spaceship"].players["foo"].ammo == ammo
  end

  test "shows 'gun is full' message if gun is full", %{state: state} do
    ammo = {max_loaded_ammo(), 3}

    state =
      state
      |> ServerState.add_room("spaceship", "foo")
      |> ServerState.update_room("spaceship", fn room ->
        Room.update_player(room, "foo", &Map.put(&1, :ammo, ammo))
      end)

    assert {:error, state, message} = CommandExecutor.execute(state, "foo", "reload")
    assert message == "Your gun is full"
    assert state.rooms["spaceship"].players["foo"].ammo == ammo
  end
end
