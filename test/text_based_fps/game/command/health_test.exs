defmodule TextBasedFPS.Game.Command.HealthTest do
  use TextBasedFPS.GameCase, async: true

  alias TextBasedFPS.Game.{CommandExecutor, Room}
  alias TextBasedFPS.GameState

  setup do
    create_player("foo")
    join_room("foo", "spaceship")
    :ok
  end

  test "requires player to be in a room" do
    GameState.update_player("foo", &%{&1 | room: nil})
    assert {:error, error_message} = CommandExecutor.execute("foo", "health")
    assert error_message =~ "You need to be in a room"
  end

  test "returns health" do
    GameState.update_room("spaceship", fn room ->
      Room.update_player(room, "foo", &%{&1 | health: 50})
    end)

    assert {:ok, "Health: 50%"} = CommandExecutor.execute("foo", "health")
  end

  test "works when the player is dead" do
    GameState.update_room("spaceship", &Room.kill_player(&1, "foo"))
    assert {:ok, "Health: 0%"} = CommandExecutor.execute("foo", "health")
  end
end
