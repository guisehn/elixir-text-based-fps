defmodule TextBasedFPS.Game.Command.LeaveRoomTest do
  use TextBasedFPS.GameCase, async: true

  alias TextBasedFPS.Game.{CommandExecutor, Room}
  alias TextBasedFPS.Process

  setup do
    create_player("foo")
    join_room("foo", "spaceship")

    create_player("bar")
    join_room("bar", "spaceship")

    :ok
  end

  test "requires player to be in a room" do
    Process.Players.update_player("foo", &%{&1 | room: nil})
    assert {:error, error_message} = CommandExecutor.execute("foo", "leave-room")
    assert error_message =~ "You need to be in a room"
  end

  test "removes player from current room" do
    expect_notification()

    assert {:ok, message} = CommandExecutor.execute("foo", "leave-room")
    assert message =~ "You have left the room"
    room = Process.Room.get("spaceship")
    refute Map.has_key?(room.players, "foo")
  end

  test "notifies other players on the same room" do
    # adds a new player and a new room to assert that the player on the other room is not notified
    create_player("qux")
    join_room("qux", "another-room")

    expect_notification(fn _, "\e[33mfoo left the room\e[0m" -> nil end)
    assert {:ok, _} = CommandExecutor.execute("foo", "leave-room")
  end

  test "removes room when only one player was on it" do
    Process.Room.update("spaceship", &Room.remove_player(&1, "bar"))

    assert {:ok, _} = CommandExecutor.execute("foo", "leave-room")
    refute Process.Room.exists?("spaceship")
  end
end
