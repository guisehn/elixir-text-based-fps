defmodule TextBasedFPS.PlayerCommands.LookTest do
  use ExUnit.Case, async: true

  alias TextBasedFPS.{
    CommandExecutor,
    Room,
    ServerState,
    Text
  }

  alias TextBasedFPS.GameMap.Objects

  setup do
    state = ServerState.new() |> ServerState.add_player("foo")
    %{state: state}
  end

  test "requires player to be in a room", %{state: state} do
    assert {:error, %ServerState{}, error_message} = CommandExecutor.execute(state, "foo", "look")
    assert error_message =~ "You need to be in a room"
  end

  test "requires player to be alive", %{state: state} do
    state =
      state
      |> ServerState.add_room("spaceship", "foo")
      |> ServerState.update_room("spaceship", &Room.kill_player(&1, "foo"))

    assert {:error, %ServerState{}, error_message} = CommandExecutor.execute(state, "foo", "look")
    assert error_message =~ "You're dead"
  end

  describe "vision of player" do
    setup [:set_up_game_environment]

    defp set_up_game_environment(%{state: state} = context) do
      # Creates a room and places the players on the map like this:
      #
      #  # # # # # # # # # #
      #  #     ¶ #         #
      #  #   #       # #   #
      #  # ▼ #   #         #
      #  #       # #   # # #
      #  # #               #
      #  # ►   #   # # #   #
      #  #   # #       #   #
      #  # ▲     ◄ #       #
      #  # # # # # # # # # #
      #
      # The one on the bottom left is the player "foo", and the others are "enemy1", "enemy2"
      # and "enemy3".
      state =
        state
        |> ServerState.add_player("enemy1")
        |> ServerState.add_player("enemy2")
        |> ServerState.add_room("spaceship", "foo")
        |> ServerState.join_room!("spaceship", "enemy1")
        |> ServerState.join_room!("spaceship", "enemy2")
        |> ServerState.join_room!("spaceship", "enemy3")
        |> ServerState.update_room("spaceship", fn room ->
          room
          |> Room.remove_player_from_map("foo")
          |> Room.remove_player_from_map("enemy1")
          |> Room.remove_player_from_map("enemy2")
          |> Room.remove_player_from_map("enemy3")
          |> Room.place_player_at!("foo", {1, 8})
          |> Room.place_player_at!("enemy1", {1, 6})
          |> Room.place_player_at!("enemy2", {4, 8})
          |> Room.place_player_at!("enemy3", {1, 3})
          |> Room.add_object({3, 1}, Objects.AmmoPack)
          |> Room.update_player("foo", &Map.put(&1, :direction, :north))
          |> Room.update_player("enemy1", &Map.put(&1, :direction, :east))
          |> Room.update_player("enemy2", &Map.put(&1, :direction, :west))
          |> Room.update_player("enemy3", &Map.put(&1, :direction, :south))
        end)

      Map.put(context, :state, state)
    end

    test "shows the player vision", %{state: state} do
      assert {:ok, %ServerState{}, vision} = CommandExecutor.execute(state, "foo", "look")
      unpainted_vision = Text.unpaint(vision)

      assert unpainted_vision ==
               String.trim("""
               # # # # # # # # # #
               #     ¶ #         #
               #   #       # #   #
               # ▼ #   #         #
               #       # #   # # #
               # #               #
               # ►   #   # # #   #
               #   # #       #   #
               # ▲     ◄ #       #
               # # # # # # # # # #
               """)

      assert Text.find_painted_text(vision, :success) == ["▲"]
      assert Text.find_painted_text(vision, :danger) == ["▼", "►", "◄"]
      assert Text.find_painted_text(vision, :info) == ["¶"]
    end
  end
end
