defmodule TextBasedFPS.Game.Command.SetNameTest do
  use TextBasedFPS.GameCase, async: true

  alias TextBasedFPS.Game.{CommandExecutor}
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

    Process.RoomSupervisor.add_room(name: "spaceship", first_player_key: "foo")
    Process.Players.update_player("foo", &%{&1 | room: "spaceship"})
    assert {:ok, message} = CommandExecutor.execute("foo", "set-name new-name")
    refute message =~ "join-room <room-name>"
  end

  test "validates the name" do
    assert {:error, _} = CommandExecutor.execute("foo", "set-name Invalid name!!!")
  end

  # test "notifies players on the same room", %{state: state} do
  #   {:ok, state, message} =
  #     state
  #     |> ServerState.add_player("qux")
  #     |> ServerState.add_player("bar")
  #     |> ServerState.add_player("player-in-another-room")
  #     |> ServerState.update_player("foo", &Map.put(&1, :name, "gui"))
  #     |> ServerState.add_room("spaceship", "foo")
  #     |> ServerState.join_room!("spaceship", "bar")
  #     |> ServerState.join_room!("spaceship", "qux")
  #     |> ServerState.add_room("another-room", "player-in-another-room")
  #     |> CommandExecutor.execute("foo", "set-name new-name")

  #   assert message =~ "Your name is now new-name."

  #   assert [
  #            %TextBasedFPS.Notification{
  #              body: "\e[33mgui changed their name to new-name\e[0m",
  #              created_at: %DateTime{},
  #              player_key: "bar"
  #            },
  #            %TextBasedFPS.Notification{
  #              body: "\e[33mgui changed their name to new-name\e[0m",
  #              created_at: %DateTime{},
  #              player_key: "qux"
  #            }
  #          ] = state.notifications
  # end
end
