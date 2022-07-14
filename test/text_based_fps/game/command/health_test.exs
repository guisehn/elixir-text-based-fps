defmodule TextBasedFPS.Game.Command.HealthTest do
  use TextBasedFPS.GameCase, async: true

  alias TextBasedFPS.Game.{CommandExecutor, Room}
  alias TextBasedFPS.Process

  setup do
    Process.Players.add_player("foo")
    Process.RoomSupervisor.add_room(name: "spaceship", first_player_key: "foo")
    Process.Players.update_player("foo", &%{&1 | room: "spaceship"})
    :ok
  end

  test "requires player to be in a room" do
    Process.Players.update_player("foo", &%{&1 | room: nil})
    assert {:error, error_message} = CommandExecutor.execute("foo", "health")
    assert error_message =~ "You need to be in a room"
  end

  test "returns health" do
    Process.Room.update("spaceship", fn room ->
      Room.update_player(room, "foo", &%{&1 | health: 50})
    end)

    assert {:ok, "Health: 50%"} = CommandExecutor.execute("foo", "health")
  end

  test "works when the player is dead" do
    Process.Room.update("spaceship", &Room.kill_player(&1, "foo"))
    assert {:ok, "Health: 0%"} = CommandExecutor.execute("foo", "health")
  end
end
