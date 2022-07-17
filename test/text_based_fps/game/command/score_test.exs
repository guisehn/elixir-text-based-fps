defmodule TextBasedFPS.Game.Command.ScoreTest do
  use TextBasedFPS.GameCase, async: true

  alias TextBasedFPS.Game.{CommandExecutor, Room}
  alias TextBasedFPS.GameState

  setup do
    create_player("foo")
  end

  test "requires player to be in a room" do
    assert {:error, msg} = CommandExecutor.execute("foo", "score")
    assert msg =~ "You need to be in a room"
  end

  test "returns score" do
    create_player("bar")
    create_player("qux")

    join_room("foo", "spaceship")
    join_room("bar", "spaceship")
    join_room("qux", "spaceship")

    GameState.update_room("spaceship", fn room ->
      room
      |> Room.update_player("bar", &%{&1 | kills: 5, killed: 10})
      |> Room.update_player("qux", &%{&1 | kills: 10, killed: 5})
    end)

    assert {:ok, score} = CommandExecutor.execute("foo", "score")

    assert score == """
           +------+-------+--------+
           | Name | Score | Deaths |
           +------+-------+--------+
           | qux  | 10    | 5      |
           | bar  | 5     | 10     |
           | foo  | 0     | 0      |
           +------+-------+--------+
           """
  end
end
