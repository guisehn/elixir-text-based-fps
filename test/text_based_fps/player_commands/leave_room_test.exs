defmodule TextBasedFPS.PlayerCommands.LeaveRoomTest do
  alias TextBasedFPS.{CommandExecutor, ServerState}

  use ExUnit.Case, async: true

  setup do
    state =
      ServerState.new()
      |> ServerState.add_player("foo")
      |> ServerState.update_player("foo", &Map.put(&1, :name, "foo"))
      |> ServerState.add_player("bar")
      |> ServerState.update_player("bar", &Map.put(&1, :name, "bar"))
      |> ServerState.add_room("spaceship", "foo")
      |> ServerState.join_room!("spaceship", "bar")

    %{state: state}
  end

  test "requires player to be in a room", %{state: state} do
    state = ServerState.remove_player_from_current_room(state, "foo")

    assert {:error, %ServerState{}, error_message} =
             CommandExecutor.execute(state, "foo", "leave-room")

    assert error_message =~ "You need to be in a room"
  end

  test "removes player from current room", %{state: state} do
    assert {:ok, state, message} = CommandExecutor.execute(state, "foo", "leave-room")
    assert message =~ "You have left the room"
    refute Map.has_key?(state.rooms["spaceship"].players, "foo")
  end

  test "notifies other players on the same room", %{state: state} do
    # adds a new player and a new room to assert that the player on the other room is not notified
    {_, state} =
      state
      |> ServerState.add_player("qux")
      |> ServerState.update_player("qux", &Map.put(&1, :name, "qux"))
      |> ServerState.add_room("another_room", "qux")
      |> ServerState.get_and_clear_notifications()

    assert {:ok, state, _} = CommandExecutor.execute(state, "foo", "leave-room")

    assert [
             %TextBasedFPS.Notification{
               body: "\e[33mfoo left the room\e[0m",
               created_at: %DateTime{},
               player_key: "bar"
             }
           ] = state.notifications
  end

  test "removes room when only one player was on it", %{state: state} do
    state = ServerState.remove_player_from_current_room(state, "bar")
    assert {:ok, state, _} = CommandExecutor.execute(state, "foo", "leave-room")
    refute Map.has_key?(state.rooms, "spaceship")
  end
end
