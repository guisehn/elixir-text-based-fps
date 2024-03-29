defmodule TextBasedFPS.Game.Command.AmmoTest do
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
    assert {:error, error_message} = CommandExecutor.execute("foo", "ammo")
    assert error_message =~ "You need to be in a room"
  end

  test "returns ammo" do
    GameState.update_room("spaceship", fn room ->
      Room.update_player(room, "foo", &%{&1 | ammo: {2, 3}})
    end)

    assert {:ok, "Ammo: 2/3"} = CommandExecutor.execute("foo", "ammo")
  end
end
