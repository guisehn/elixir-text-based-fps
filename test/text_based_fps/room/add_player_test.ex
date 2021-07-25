defmodule TextBasedFPS.Room.AddPlayerTest do
  alias TextBasedFPS.{GameMap, Room, RoomPlayer}
  alias TextBasedFPS.GameMap.Matrix

  use ExUnit.Case, async: true

  describe "add_player/2" do
    test "adds player to room and adds them to the game map" do
      {:ok, room} = new_test_room() |> Room.add_player("foo")
      assert_player_added(room, "foo")
    end

    test "returns error when room is full (players in room = amount of respawn positions)" do
      room = new_test_room()
      assert {:ok, room} = Room.add_player(room, "foo")
      assert {:ok, room} = Room.add_player(room, "bar")
      assert {:error, ^room, :room_full} = Room.add_player(room, "baz")
    end
  end

  describe "add_player!/2" do
    test "adds player to room and adds them to the game map" do
      room = new_test_room() |> Room.add_player!("foo")
      assert_player_added(room, "foo")
    end

    test "returns error when room is full (players in room = amount of respawn positions)" do
      room =
        new_test_room()
        |> Room.add_player!("foo")
        |> Room.add_player!("bar")

      assert_raise RuntimeError, "Cannot add player. Reason: room_full", fn ->
        Room.add_player!(room, "baz")
      end
    end
  end

  defp new_test_room do
    Room.new("room")
    # game map composed of two respawn positions only
    |> Map.put(:game_map, GameMap.Builder.build("NN"))
  end

  defp assert_player_added(room, player_name) do
    assert Map.has_key?(room.players, player_name) == true
    assert room.players[player_name].health == RoomPlayer.max_health()
    assert room.players[player_name].coordinates != nil
    assert room.players[player_name].direction != nil
    assert room.players[player_name].ammo != {0, 0}

    assert Matrix.player_at?(
             room.game_map.matrix,
             room.players[player_name].coordinates,
             player_name
           ) ==
             true
  end
end
