defmodule TextBasedFPS.CommandHelperTest do
  alias TextBasedFPS.CommandHelper
  alias TextBasedFPS.Room
  alias TextBasedFPS.ServerState

  use ExUnit.Case, async: true

  setup do
    state = ServerState.new() |> ServerState.add_player("foo")
    %{state: state}
  end

  describe "require_room/2" do
    test "returns {:ok, room} if player is in a room", %{state: state} do
      state = ServerState.add_room(state, "spaceship", "foo")
      player = ServerState.get_player(state, "foo")
      assert {:ok, %Room{}} = CommandHelper.require_room(state, player)
    end

    test "returns {:ok, state, error_message} if player is not in a room", %{state: state} do
      player = ServerState.get_player(state, "foo")
      assert {:error, ^state, error_message} = CommandHelper.require_room(state, player)
      assert error_message =~ "You need to be in a room to use this command"
    end
  end

  describe "require_alive_player/2" do
    test "returns {:ok, room} if player is in a room and is alive", %{state: state} do
      state = ServerState.add_room(state, "spaceship", "foo")
      player = ServerState.get_player(state, "foo")
      assert {:ok, %Room{}} = CommandHelper.require_alive_player(state, player)
    end

    test "returns {:ok, state, error_message} if player is in a room but is dead", %{state: state} do
      state = state
      |> ServerState.add_room("spaceship", "foo")
      |> ServerState.update_room("spaceship", &(Room.kill_player(&1, "foo")))

      player = ServerState.get_player(state, "foo")

      assert {:error, ^state, error_message} = CommandHelper.require_alive_player(state, player)
      assert error_message =~ "You're dead"
    end

    test "returns {:ok, state, error_message} if player is not in a room", %{state: state} do
      player = ServerState.get_player(state, "foo")
      assert {:error, ^state, error_message} = CommandHelper.require_alive_player(state, player)
      assert error_message =~ "You need to be in a room to use this command"
    end
  end
end
