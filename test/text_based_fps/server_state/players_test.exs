defmodule TextBasedFPS.ServerState.PlayersTest do
  use ExUnit.Case, async: true

  alias TextBasedFPS.{Player, ServerState}

  describe "add_player/1" do
    test "adds a player returning its generated key" do
      {player_key, state} = ServerState.new() |> ServerState.add_player()
      assert %Player{key: ^player_key} = state.players[player_key]
    end
  end

  describe "add_player/2" do
    test "adds a player with the given key" do
      state = ServerState.new() |> ServerState.add_player("foo")
      assert %Player{key: "foo"} = state.players["foo"]
    end

    test "does nothing when player with key already exists" do
      state = ServerState.new() |> ServerState.add_player("foo")
      updated_state = ServerState.add_player(state, "foo")
      assert updated_state == state
    end
  end

  describe "update_player/3" do
    test "updates player using the given function" do
      state =
        ServerState.new()
        |> ServerState.add_player("foo")
        |> ServerState.update_player("foo", &Map.put(&1, :name, "bar"))

      assert %Player{key: "foo", name: "bar"} = state.players["foo"]
    end

    test "does nothing when player doesn't exist" do
      state =
        ServerState.new()
        |> ServerState.update_player("foo", &Map.put(&1, :name, "bar"))

      refute Map.has_key?(state.players, "foo")
    end
  end

  describe "remove_player/2" do
    test "removes player from the server" do
      state =
        ServerState.new()
        |> ServerState.add_player("foo")
        |> ServerState.remove_player("foo")

      refute Map.has_key?(state.players, "foo")
    end

    test "removes player from their current room" do
      state =
        ServerState.new()
        |> ServerState.add_player("foo")
        |> ServerState.add_player("bar")
        |> ServerState.add_room("spaceship", "foo")
        |> ServerState.join_room!("spaceship", "bar")
        |> ServerState.remove_player("foo")

      refute Map.has_key?(state.players, "foo")
      refute Map.has_key?(state.rooms["spaceship"].players, "foo")
    end

    test "does nothing when player doesn't exist" do
      state =
        ServerState.new()
        |> ServerState.remove_player("foo")

      refute Map.has_key?(state.players, "foo")
    end
  end

  describe "get_player/2" do
    test "returns player with given key" do
      state = ServerState.new() |> ServerState.add_player("foo")
      assert %Player{key: "foo"} = ServerState.get_player(state, "foo")
    end

    test "returns nil when player doesn't exist" do
      state = ServerState.new()
      assert ServerState.get_player(state, "foo") == nil
    end
  end
end
