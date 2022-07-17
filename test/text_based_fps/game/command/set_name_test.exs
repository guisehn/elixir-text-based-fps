defmodule TextBasedFPS.Game.Command.SetNameTest do
  use TextBasedFPS.GameCase, async: true

  alias TextBasedFPS.Game.CommandExecutor
  alias TextBasedFPS.GameState

  setup do
    create_player("foo")
    :ok
  end

  test "changes the player name" do
    assert {:ok, message} = CommandExecutor.execute("foo", "set-name gui")
    assert GameState.get_player("foo").name == "gui"
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
    Enum.each(["foo", "qux", "bar"], fn player ->
      create_player(player)
      join_room(player, "spaceship")
    end)

    create_player("player-in-another-room")
    join_room("player-in-another-room", "another-room")

    expect_notifications(2, fn _, msg ->
      assert msg == "\e[33mfoo changed their name to new-name\e[0m"
    end)

    assert {:ok, message} = CommandExecutor.execute("foo", "set-name new-name")
    assert message =~ "Your name is now new-name."
  end
end
