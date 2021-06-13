defmodule TextBasedFPS.PlayerCommands.RoomListTest do
  alias TextBasedFPS.CommandExecutor
  alias TextBasedFPS.ServerState

  use ExUnit.Case, async: true

  test "returns list of rooms sorted by amount of players" do
    assert {:ok, %ServerState{}, room_list} =
             ServerState.new()
             |> ServerState.add_player("foo")
             |> ServerState.add_player("bar")
             |> ServerState.add_player("qux")
             |> ServerState.add_room("spaceship", "foo")
             |> ServerState.add_room("canyon", "baz")
             |> ServerState.join_room("canyon", "qux")
             |> ServerState.add_room("forest")
             |> CommandExecutor.execute("foo", "room-list")

    assert room_list == """
           +-----------+---------+
           | Name      | Players |
           +-----------+---------+
           | canyon    | 2       |
           | spaceship | 1       |
           | forest    | 0       |
           +-----------+---------+
           """
  end
end
