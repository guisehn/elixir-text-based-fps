defmodule TextBasedFPS.PlayerCommands.ScoreTest do
  alias TextBasedFPS.CommandExecutor
  alias TextBasedFPS.ServerState
  alias TextBasedFPS.Room

  use ExUnit.Case, async: true

  setup do
    {_, server_state} = ServerState.new() |> ServerState.add_player("foo")
    %{state: server_state}
  end

  test "requires player to be in a room", %{state: state} do
    assert {:error, _state, error_message} = CommandExecutor.execute(state, "foo", "score")
    assert error_message =~ "You need to be in a room"
  end

  test "returns score", %{state: state} do
    {_, state} = ServerState.add_player(state, "qux")
    {_, state} = ServerState.add_player(state, "bar")

    state = state
    |> ServerState.update_player("foo", &(Map.put(&1, :name, "foo")))
    |> ServerState.update_player("bar", &(Map.put(&1, :name, "bar")))
    |> ServerState.update_player("qux", &(Map.put(&1, :name, "qux")))
    |> ServerState.add_room("spaceship", "foo")
    |> ServerState.join_room("spaceship", "bar")
    |> ServerState.join_room("spaceship", "qux")
    |> ServerState.update_room("spaceship", fn room ->
      room
      |> Room.update_player("qux", &(Map.put(&1, :kills, 10)))
      |> Room.update_player("qux", &(Map.put(&1, :killed, 5)))
      |> Room.update_player("bar", &(Map.put(&1, :kills, 5)))
      |> Room.update_player("bar", &(Map.put(&1, :killed, 10)))
    end)

    assert {:ok, _state, score} = CommandExecutor.execute(state, "foo", "score")

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
