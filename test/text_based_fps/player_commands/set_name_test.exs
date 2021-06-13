defmodule TextBasedFPS.PlayerCommands.SetNameTest do
  alias TextBasedFPS.CommandExecutor
  alias TextBasedFPS.ServerState

  use ExUnit.Case, async: true

  setup do
    state = ServerState.new() |> ServerState.add_player("foo")
    %{state: state}
  end

  test "changes the player name", %{state: state} do
    assert {:ok, state, message} = CommandExecutor.execute(state, "foo", "set-name gui")
    assert ServerState.get_player(state, "foo").name == "gui"
    assert message =~ "Your name is now gui."
  end

  test "lets the player know that they can now join a room if they're not in a room", %{
    state: state
  } do
    assert {:ok, state, message} = CommandExecutor.execute(state, "foo", "set-name gui")
    assert message =~ "join-room <room-name>"

    state = ServerState.add_room(state, "spaceship", "foo")
    assert {:ok, _, message} = CommandExecutor.execute(state, "foo", "set-name new-name")
    refute message =~ "join-room <room-name>"
  end

  test "validates the name", %{state: state} do
    assert {:error, _, _} = CommandExecutor.execute(state, "foo", "set-name Invalid name!!!")
  end

  test "notifies players on the same room", %{state: state} do
    {:ok, state, message} =
      state
      |> ServerState.add_player("qux")
      |> ServerState.add_player("bar")
      |> ServerState.add_player("player-in-another-room")
      |> ServerState.update_player("foo", &Map.put(&1, :name, "gui"))
      |> ServerState.add_room("spaceship", "foo")
      |> ServerState.join_room("spaceship", "bar")
      |> ServerState.join_room("spaceship", "qux")
      |> ServerState.add_room("another-room", "player-in-another-room")
      |> CommandExecutor.execute("foo", "set-name new-name")

    assert message =~ "Your name is now new-name."

    assert [
             %TextBasedFPS.Notification{
               body: "\e[33mgui changed their name to new-name\e[0m",
               created_at: %DateTime{},
               player_key: "bar"
             },
             %TextBasedFPS.Notification{
               body: "\e[33mgui changed their name to new-name\e[0m",
               created_at: %DateTime{},
               player_key: "qux"
             }
           ] = state.notifications
  end
end
