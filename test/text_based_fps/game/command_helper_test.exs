defmodule TextBasedFPS.Game.CommandHelperTest do
  use ExUnit.Case, async: true

  alias TextBasedFPS.Game.{CommandHelper, Player, Room}
  alias TextBasedFPS.Process

  describe "require_room/1" do
    test "returns {:ok, room} when player is in a room" do
      Process.Players.add_player("foo")
      Process.RoomSupervisor.add_room(name: "spaceship", first_player_key: "foo")

      player = %{Process.Players.get_player("foo") | room: "spaceship"}
      assert {:ok, %Room{name: "spaceship"}} = CommandHelper.require_room(player)
    end

    test "returns {:error, error_message} when player is not in a room" do
      player = Player.new("foo")
      assert {:error, error_message} = CommandHelper.require_room(player)
      assert error_message =~ "You need to be in a room to use this command"
    end
  end

  describe "require_alive_player/2" do
    test "returns {:ok, room} when player is in a room and is alive" do
      Process.Players.add_player("foo")
      Process.RoomSupervisor.add_room(name: "spaceship", first_player_key: "foo")

      player = %{Process.Players.get_player("foo") | room: "spaceship"}
      assert {:ok, %Room{name: "spaceship"}} = CommandHelper.require_alive_player(player)
    end

    test "returns {:error, message} when player is in a room but is dead" do
      Process.Players.add_player("foo")
      Process.RoomSupervisor.add_room(name: "spaceship", first_player_key: "foo")
      Process.Room.update("spaceship", &Room.kill_player(&1, "foo"))

      player = %{Player.new("foo") | room: "spaceship"}
      assert {:error, "You're dead" <> _} = CommandHelper.require_alive_player(player)
    end

    test "returns {:error, message} when player is not in a room" do
      player = Player.new("foo")
      assert {:error, error_message} = CommandHelper.require_alive_player(player)
      assert error_message =~ "You need to be in a room to use this command"
    end
  end
end
