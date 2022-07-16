defmodule TextBasedFPS.Game.Command.SetNameTest do
  use TextBasedFPS.GameCase, async: true

  alias TextBasedFPS.Game.CommandExecutor
  alias TextBasedFPS.Process

  setup do
    Process.Players.add_player("foo")
    :ok
  end

  test "changes the player name" do
    assert {:ok, message} = CommandExecutor.execute("foo", "set-name gui")
    assert Process.Players.get_player("foo").name == "gui"
    assert message =~ "Your name is now gui."
  end

  test "lets the player know that they can now join a room if they're not in a room" do
    assert {:ok, message} = CommandExecutor.execute("foo", "set-name gui")
    assert message =~ "join-room <room-name>"

    join_room("foo", "spaceship")
    assert {:ok, message} = CommandExecutor.execute("foo", "set-name new-name")
    refute message =~ "join-room <room-name>"
  end

  test "validates the name" do
    assert {:error, _} = CommandExecutor.execute("foo", "set-name Invalid name!!!")
  end

  test "notifies players on the same room" do
    Process.Players.update_player("foo", &%{&1 | name: "gui"})

    Enum.each(["foo", "qux", "bar"], &join_room(&1, "spaceship"))
    join_room("player-in-another-room", "another-room")

    expect_notifications(2, fn _, msg ->
      assert msg == "\e[33mgui changed their name to new-name\e[0m"
    end)

    assert {:ok, message} = CommandExecutor.execute("foo", "set-name new-name")
    assert message =~ "Your name is now new-name."
  end
end
