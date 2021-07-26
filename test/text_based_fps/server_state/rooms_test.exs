defmodule TextBasedFPS.ServerState.RoomsTest do
  use ExUnit.Case, async: true

  alias TextBasedFPS.{Room, ServerState}

  describe "add_room/2" do
    test "adds a room with no players" do
      state = ServerState.new() |> ServerState.add_room("spaceship")
      assert %Room{name: "spaceship"} = state.rooms["spaceship"]
    end
  end

  describe "add_room/3" do
    test "adds a room with the given player" do
      state =
        ServerState.new()
        |> ServerState.add_player("foo")
        |> ServerState.add_room("spaceship", "foo")

      assert %Room{name: "spaceship"} = state.rooms["spaceship"]
      assert state.rooms["spaceship"].players["foo"] != nil
    end
  end

  describe "get_room/2" do
    test "returns existing room" do
      state = ServerState.new() |> ServerState.add_room("spaceship")
      assert %Room{name: "spaceship"} = ServerState.get_room(state, "spaceship")
    end

    test "returns nil if room does not exist" do
      state = ServerState.new()
      assert ServerState.get_room(state, "spaceship") == nil
    end
  end

  describe "update_room/2" do
    test "updates room" do
      state =
        ServerState.new()
        |> ServerState.add_player("foo")
        |> ServerState.add_room("spaceship", "foo")

      room = state.rooms["spaceship"]
      updated_room = put_in(room.players["foo"].health, 50)

      state = ServerState.update_room(state, updated_room)
      assert state.rooms["spaceship"] == updated_room
    end
  end

  describe "update_room/3" do
    test "updates room using function" do
      state =
        ServerState.new()
        |> ServerState.add_player("foo")
        |> ServerState.add_room("spaceship", "foo")
        |> ServerState.update_room("spaceship", fn room ->
          put_in(room.players["foo"].health, 50)
        end)

      assert state.rooms["spaceship"].players["foo"].health == 50
    end
  end
end
