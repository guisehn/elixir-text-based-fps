defmodule TextBasedFPS.Game.Command.FireTest do
  use TextBasedFPS.GameCase, async: true

  alias TextBasedFPS.Game.{CommandExecutor, Room, RoomPlayer}
  alias TextBasedFPS.{GameState, Text}

  setup do
    create_player("foo")
    join_room("foo", "spaceship")
    :ok
  end

  test "requires player to be in a room" do
    GameState.Players.update_player("foo", &%{&1 | room: nil})
    assert {:error, error_message} = CommandExecutor.execute("foo", "move")
    assert error_message =~ "You need to be in a room"
  end

  test "requires player to be alive" do
    GameState.Room.update("spaceship", &Room.kill_player(&1, "foo"))

    assert {:error, error_message} = CommandExecutor.execute("foo", "turn east")
    assert error_message =~ "You're dead"
  end

  test "requires player to have loaded ammo" do
    GameState.Room.update("spaceship", fn room ->
      Room.update_player(room, "foo", &%{&1 | ammo: {0, 5}})
    end)

    assert {:error, error_message} = CommandExecutor.execute("foo", "fire")
    assert error_message =~ "Reload your gun"
    assert GameState.Room.get("spaceship").players["foo"].ammo == {0, 5}
  end

  test "returns specific message when the player is out of ammo" do
    GameState.Room.update("spaceship", fn room ->
      Room.update_player(room, "foo", &%{&1 | ammo: {0, 0}})
    end)

    assert {:error, error_message} = CommandExecutor.execute("foo", "fire")
    assert error_message =~ "You're out of ammo"
    assert GameState.Room.get("spaceship").players["foo"].ammo == {0, 0}
  end

  test "decrements the ammo" do
    GameState.Room.update("spaceship", fn room ->
      Room.update_player(room, "foo", &%{&1 | ammo: {5, 8}})
    end)

    assert {:ok, _message} = CommandExecutor.execute("foo", "fire")
    assert GameState.Room.get("spaceship").players["foo"].ammo == {4, 8}
  end

  describe "shot enemy" do
    setup [:set_up_game_environment]

    defp set_up_game_environment(_) do
      create_player("enemy")
      join_room("enemy", "spaceship")

      GameState.Room.update("spaceship", fn room ->
        room
        |> Room.remove_player_from_map("foo")
        |> Room.remove_player_from_map("enemy")
      end)

      :ok
    end

    test "hits enemies in the player direction" do
      #          # # # # # # # # # #
      #          #       #         #
      #          #   #       # #   #
      #          #   #   #         #
      #          #       # #   # # #
      #          # #               #
      # enemy -> # ▼   #   # # #   #
      #          #   # #       #   #
      #   foo -> # ▲       #       #
      #          # # # # # # # # # #
      GameState.Room.update("spaceship", fn room ->
        room
        |> Room.place_player_at!("foo", {1, 8})
        |> Room.update_player("foo", &Map.put(&1, :direction, :north))
        |> Room.place_player_at!("enemy", {1, 6})
        |> Room.update_player("enemy", &Map.put(&1, :direction, :south))
      end)

      # notifies hit enemy
      notification_body = Text.danger("uh oh! foo shot you!")
      expect_notification(fn "enemy", ^notification_body -> nil end)

      assert {:ok, error_message} = CommandExecutor.execute("foo", "fire")
      assert error_message =~ "You've hit enemy"

      # damage is this value because the enemy is more than one position away from the shooter
      # formula = 30 (normal power) - 1 (it decreases 1 for each position of distance)
      expected_damage = 29

      assert GameState.Room.get("spaceship").players["enemy"].health ==
               RoomPlayer.max_health() - expected_damage
    end

    test "kills enemy when their health is too low" do
      #          # # # # # # # # # #
      #          #       #         #
      #          #   #       # #   #
      #          #   #   #         #
      #          #       # #   # # #
      #          # #               #
      # enemy -> # ▼   #   # # #   #
      #          #   # #       #   #
      #   foo -> # ▲       #       #
      #          # # # # # # # # # #
      GameState.Room.update("spaceship", fn room ->
        room
        |> Room.place_player_at!("foo", {1, 8})
        |> Room.update_player("foo", &Map.put(&1, :direction, :north))
        |> Room.place_player_at!("enemy", {1, 6})
        |> Room.update_player("enemy", &Map.put(&1, :direction, :south))
        |> Room.update_player("enemy", &Map.put(&1, :health, 10))
      end)

      # notifies hit enemy
      expect_notification(fn "enemy", msg ->
        assert msg =~ "foo killed you!"
      end)

      assert {:ok, error_message} = CommandExecutor.execute("foo", "fire")
      assert error_message =~ "You've killed enemy"
      room = GameState.Room.get("spaceship")
      assert room.players["enemy"].health == 0
      assert room.players["enemy"].killed == 1
      assert room.players["foo"].kills == 1
    end

    test "doesn't hit enemies behind walls" do
      #          # # # # # # # # # #
      #          #       #         #
      #          #   #       # #   #
      #          #   #   #         #
      # enemy -> # ▼     # #   # # #
      #          # #               #
      #   foo -> # ▲   #   # # #   #
      #          #   # #       #   #
      #          #         #       #
      #          # # # # # # # # # #
      GameState.Room.update("spaceship", fn room ->
        room
        |> Room.place_player_at!("foo", {1, 6})
        |> Room.update_player("foo", &Map.put(&1, :direction, :north))
        |> Room.place_player_at!("enemy", {1, 4})
        |> Room.update_player("enemy", &Map.put(&1, :direction, :south))
      end)

      assert {:ok, error_message} = CommandExecutor.execute("foo", "fire")
      assert error_message =~ "You've shot the wall"

      assert GameState.Room.get("spaceship").players["enemy"].health == RoomPlayer.max_health()
    end

    test "allows multiple players to be hit" do
      #           # # # # # # # # # #
      #           #       #         #
      #           #   #       # #   #
      #           #   #   #         #
      #           #       # #   # # #
      #           # #               #
      #  enemy -> # ▼   #   # # #   #
      # enemy2 -> # ► # #       #   #
      #    foo -> # ▲       #       #
      #           # # # # # # # # # #
      create_player("enemy2")
      join_room("enemy2", "spaceship")

      GameState.Room.update("spaceship", fn room ->
        room
        |> Room.remove_player_from_map("enemy2")
        |> Room.place_player_at!("foo", {1, 8})
        |> Room.update_player("foo", &Map.put(&1, :direction, :north))
        |> Room.place_player_at!("enemy", {1, 6})
        |> Room.update_player("enemy", &Map.put(&1, :direction, :south))
        |> Room.place_player_at!("enemy2", {1, 7})
        |> Room.update_player("enemy2", &Map.put(&1, :direction, :east))
      end)

      expect_notifications(2)

      assert {:ok, error_message} = CommandExecutor.execute("foo", "fire")
      assert error_message =~ "You've hit enemy2, enemy"

      # damage to enemy2 is maximum because they're only one position far from the shooter player
      expected_damage = 30

      assert GameState.Room.get("spaceship").players["enemy2"].health ==
               RoomPlayer.max_health() - expected_damage

      # damage to enemy is this value because:
      # - there's a player hit before, and each player hit decreases 10 of damage from the next one
      # - the enemy is two positions away (reduces 1)
      expected_damage = 30 - 10 - 1

      assert GameState.Room.get("spaceship").players["enemy"].health ==
               RoomPlayer.max_health() - expected_damage
    end
  end
end
