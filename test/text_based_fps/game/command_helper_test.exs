defmodule TextBasedFPS.Game.CommandHelperTest do
  use TextBasedFPS.GameCase, async: true

  alias TextBasedFPS.Game.{CommandHelper, Room}
  alias TextBasedFPS.Process

  describe "require_room/1" do
    test "returns {:ok, room} when player is in a room" do
      create_player("foo")
      join_room("foo", "spaceship")

      player = Process.get_player("foo")
      assert {:ok, %Room{name: "spaceship"}} = CommandHelper.require_room(player)
    end

    test "returns {:error, error_message} when player is not in a room" do
      create_player("foo")

      player = Process.get_player("foo")
      assert {:error, error_message} = CommandHelper.require_room(player)
      assert error_message =~ "You need to be in a room to use this command"
    end
  end

  describe "require_alive_player/1" do
    test "returns {:ok, room} when player is in a room and is alive" do
      create_player("foo")
      join_room("foo", "spaceship")

      player = Process.get_player("foo")
      assert {:ok, %Room{name: "spaceship"}} = CommandHelper.require_alive_player(player)
    end

    test "returns {:error, message} when player is in a room but is dead" do
      create_player("foo")
      join_room("foo", "spaceship")
      Process.Room.update("spaceship", &Room.kill_player(&1, "foo"))

      player = Process.get_player("foo")
      assert {:error, "You're dead" <> _} = CommandHelper.require_alive_player(player)
    end

    test "returns {:error, message} when player is not in a room" do
      create_player("foo")

      player = Process.get_player("foo")
      assert {:error, error_message} = CommandHelper.require_alive_player(player)
      assert error_message =~ "You need to be in a room to use this command"
    end
  end
end
