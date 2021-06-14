defmodule TextBasedFPS.PlayerCommands.FireTest do
  alias TextBasedFPS.CommandExecutor
  alias TextBasedFPS.Room
  alias TextBasedFPS.RoomPlayer
  alias TextBasedFPS.ServerState
  alias TextBasedFPS.Text

  use ExUnit.Case, async: true

  setup do
    state =
      ServerState.new()
      |> ServerState.add_player("foo")
      |> ServerState.update_player("foo", &Map.put(&1, :name, "foo"))
      |> ServerState.add_room("spaceship", "foo")

    %{state: state}
  end

  test "requires player to be in a room", %{state: state} do
    state = ServerState.remove_player_from_current_room(state, "foo")
    assert {:error, %ServerState{}, error_message} = CommandExecutor.execute(state, "foo", "fire")
    assert error_message =~ "You need to be in a room"
  end

  test "requires player to be alive", %{state: state} do
    state = ServerState.update_room(state, "spaceship", &Room.kill_player(&1, "foo"))

    assert {:error, %ServerState{}, error_message} = CommandExecutor.execute(state, "foo", "fire")
    assert error_message =~ "You're dead"
  end

  test "requires player to have loaded ammo", %{state: state} do
    state =
      ServerState.update_room(state, "spaceship", fn room ->
        Room.update_player(room, "foo", &Map.put(&1, :ammo, {0, 5}))
      end)

    assert {:error, updated_state, error_message} = CommandExecutor.execute(state, "foo", "fire")
    assert error_message =~ "Reload your gun"
    assert updated_state.rooms["spaceship"].players["foo"].ammo == {0, 5}
  end

  test "returns specific message if the player is out of ammo", %{state: state} do
    state =
      ServerState.update_room(state, "spaceship", fn room ->
        Room.update_player(room, "foo", &Map.put(&1, :ammo, {0, 0}))
      end)

    assert {:error, updated_state, error_message} = CommandExecutor.execute(state, "foo", "fire")
    assert error_message =~ "You're out of ammo"
    assert updated_state.rooms["spaceship"].players["foo"].ammo == {0, 0}
  end

  test "decrements the ammo", %{state: state} do
    state =
      ServerState.update_room(state, "spaceship", fn room ->
        Room.update_player(room, "foo", &Map.put(&1, :ammo, {5, 8}))
      end)

    assert {:ok, updated_state, _message} = CommandExecutor.execute(state, "foo", "fire")
    assert updated_state.rooms["spaceship"].players["foo"].ammo == {4, 8}
  end

  describe "shot enemy" do
    setup [:set_up_game_environment]

    defp set_up_game_environment(%{state: state} = context) do
      state =
        state
        |> ServerState.add_player("enemy")
        |> ServerState.update_player("enemy", &Map.put(&1, :name, "enemy"))
        |> ServerState.join_room("spaceship", "enemy")
        |> ServerState.update_room("spaceship", fn room ->
          room
          |> Room.remove_player_from_map("foo")
          |> Room.remove_player_from_map("enemy")
        end)

      Map.put(context, :state, state)
    end

    test "hits enemies in the player direction", %{state: state} do
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
      state =
        state
        |> ServerState.update_room("spaceship", fn room ->
          room
          |> Room.place_player_at!("foo", {1, 8})
          |> Room.update_player("foo", &Map.put(&1, :direction, :north))
          |> Room.place_player_at!("enemy", {1, 6})
          |> Room.update_player("enemy", &Map.put(&1, :direction, :south))
        end)

      assert {:ok, updated_state, error_message} = CommandExecutor.execute(state, "foo", "fire")
      assert error_message =~ "You've hit enemy"

      # damage is this value because the enemy is more than one position away from the shooter
      # formula = 30 (normal power) - 1 (it decreases 1 for each position of distance)
      expected_damage = 29

      assert updated_state.rooms["spaceship"].players["enemy"].health ==
               RoomPlayer.max_health() - expected_damage

      # notifies hit enemy
      notification_body = Text.danger("uh oh! foo shot you!")

      assert [
               %TextBasedFPS.Notification{
                 body: ^notification_body,
                 created_at: %DateTime{},
                 player_key: "enemy"
               }
             ] = updated_state.notifications
    end

    test "kills enemy if their health is too low", %{state: state} do
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
      state =
        state
        |> ServerState.update_room("spaceship", fn room ->
          room
          |> Room.place_player_at!("foo", {1, 8})
          |> Room.update_player("foo", &Map.put(&1, :direction, :north))
          |> Room.place_player_at!("enemy", {1, 6})
          |> Room.update_player("enemy", &Map.put(&1, :direction, :south))
          |> Room.update_player("enemy", &Map.put(&1, :health, 10))
        end)

      assert {:ok, updated_state, error_message} = CommandExecutor.execute(state, "foo", "fire")
      assert error_message =~ "You've killed enemy"
      assert updated_state.rooms["spaceship"].players["enemy"].health == 0
      assert updated_state.rooms["spaceship"].players["enemy"].killed == 1
      assert updated_state.rooms["spaceship"].players["foo"].kills == 1

      # notifies hit enemy
      assert [
               %TextBasedFPS.Notification{
                 body: notification_body,
                 created_at: %DateTime{},
                 player_key: "enemy"
               }
             ] = updated_state.notifications

      assert notification_body =~ "foo killed you!"
    end

    test "doesn't hit enemies behind walls", %{state: state} do
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
      state =
        state
        |> ServerState.update_room("spaceship", fn room ->
          room
          |> Room.place_player_at!("foo", {1, 6})
          |> Room.update_player("foo", &Map.put(&1, :direction, :north))
          |> Room.place_player_at!("enemy", {1, 4})
          |> Room.update_player("enemy", &Map.put(&1, :direction, :south))
        end)

      assert {:ok, updated_state, error_message} = CommandExecutor.execute(state, "foo", "fire")
      assert error_message =~ "You've shot the wall"
      assert updated_state.rooms["spaceship"].players["enemy"].health == RoomPlayer.max_health()
      assert length(updated_state.notifications) == 0
    end

    test "allows multiple players to be hit", %{state: state} do
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
      state =
        state
        |> ServerState.add_player("enemy2")
        |> ServerState.update_player("enemy2", &Map.put(&1, :name, "enemy2"))
        |> ServerState.join_room("spaceship", "enemy2")
        |> ServerState.update_room("spaceship", fn room ->
          room
          |> Room.remove_player_from_map("enemy2")
          |> Room.place_player_at!("foo", {1, 8})
          |> Room.update_player("foo", &Map.put(&1, :direction, :north))
          |> Room.place_player_at!("enemy", {1, 6})
          |> Room.update_player("enemy", &Map.put(&1, :direction, :south))
          |> Room.place_player_at!("enemy2", {1, 7})
          |> Room.update_player("enemy2", &Map.put(&1, :direction, :east))
        end)

      assert {:ok, updated_state, error_message} = CommandExecutor.execute(state, "foo", "fire")
      assert error_message =~ "You've hit enemy2, enemy"

      # damage to enemy2 is maximum because they're only one position far from the shooter player
      expected_damage = 30

      assert updated_state.rooms["spaceship"].players["enemy2"].health ==
               RoomPlayer.max_health() - expected_damage

      # damage to enemy is this value because:
      # - there's a player hit before, and each player hit decreases 10 of damage from the next one
      # - the enemy is two positions away (reduces 1)
      expected_damage = 30 - 10 - 1

      assert updated_state.rooms["spaceship"].players["enemy"].health ==
               RoomPlayer.max_health() - expected_damage
    end
  end
end
