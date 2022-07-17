defmodule TextBasedFPS.Game.Command.LookTest do
  use TextBasedFPS.GameCase, async: true

  alias TextBasedFPS.Game.{CommandExecutor, Room}
  alias TextBasedFPS.GameMap.Objects
  alias TextBasedFPS.{GameState, Text}

  setup do
    create_player("foo")
  end

  test "requires player to be in a room" do
    assert {:error, error_message} = CommandExecutor.execute("foo", "move")
    assert error_message =~ "You need to be in a room"
  end

  test "requires player to be alive" do
    join_room("foo", "spaceship")
    GameState.update_room("spaceship", &Room.kill_player(&1, "foo"))

    assert {:error, error_message} = CommandExecutor.execute("foo", "turn east")
    assert error_message =~ "You're dead"
  end

  describe "vision of player" do
    setup [:set_up_game_environment]

    defp set_up_game_environment(_) do
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

      create_player("enemy1")
      create_player("enemy2")
      create_player("enemy3")

      join_room("foo", "spaceship")
      join_room("enemy1", "spaceship")
      join_room("enemy2", "spaceship")
      join_room("enemy3", "spaceship")

      GameState.update_room("spaceship", fn room ->
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

      :ok
    end

    test "shows the player vision" do
      assert {:ok, vision} = CommandExecutor.execute("foo", "look")
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
