defmodule TextBasedFPS.Game.Command.RoomListTest do
  use TextBasedFPS.GameCase, async: true

  alias TextBasedFPS.Game.CommandExecutor

  test "returns list of rooms sorted by amount of players" do
    create_player("foo")
    create_player("bar")
    create_player("qux")

    join_room("foo", "spaceship")
    join_room("bar", "canyon")
    join_room("qux", "canyon")

    assert {:ok, room_list} = CommandExecutor.execute("foo", "room-list")

    assert room_list == """
           +-----------+---------+
           | Name      | Players |
           +-----------+---------+
           | canyon    | 2       |
           | spaceship | 1       |
           +-----------+---------+
           """
  end
end
