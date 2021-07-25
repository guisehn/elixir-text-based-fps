defmodule TextBasedFPS.PlayerCommands.JoinRoomTest do
  alias TextBasedFPS.{CommandExecutor, ServerState, RoomPlayer}

  use ExUnit.Case, async: true

  setup do
    state =
      ServerState.new()
      |> ServerState.add_player("foo")
      |> ServerState.update_player("foo", &Map.put(&1, :name, "foo"))

    %{state: state}
  end

  describe "player requirements" do
    test "requires player to have a name", %{state: state} do
      state = ServerState.update_player(state, "foo", &Map.put(&1, :name, nil))

      assert {:error, %ServerState{}, message} =
               CommandExecutor.execute(state, "foo", "join-room spaceship")

      assert message =~ "You need to have a name before joining a room"
    end
  end

  describe "unexisting room" do
    test "creates room and adds player to it if room doesn't exist", %{state: state} do
      assert {:ok, state, message} = CommandExecutor.execute(state, "foo", "join-room spaceship")
      assert message =~ "You're now on spaceship"
      assert %{rooms: %{"spaceship" => %{players: %{"foo" => %RoomPlayer{}}}}} = state
    end

    test "validates room name", %{state: state} do
      assert {:error, %ServerState{}, message} =
               CommandExecutor.execute(state, "foo", "join-room !!!")

      assert message =~ "Room name can only contain letters, numbers and hyphens"
    end
  end

  describe "existing room" do
    setup [:setup_existing_room]

    defp setup_existing_room(%{state: state}) do
      state =
        state
        |> ServerState.add_player("bar")
        |> ServerState.update_player("bar", &Map.put(&1, :name, "bar"))
        |> ServerState.add_room("spaceship", "bar")

      %{state: state}
    end

    test "adds player to room if it exists", %{state: state} do
      assert {:ok, state, message} = CommandExecutor.execute(state, "foo", "join-room spaceship")
      assert message =~ "You're now on spaceship"

      assert %{
               rooms: %{
                 "spaceship" => %{
                   players: %{
                     "foo" => %RoomPlayer{},
                     "bar" => %RoomPlayer{}
                   }
                 }
               }
             } = state
    end

    test "notifies other players on same room", %{state: state} do
      # adds a new player and a new room to assert that the player on the other room is not notified
      {_, state} =
        state
        |> ServerState.add_player("qux")
        |> ServerState.update_player("qux", &Map.put(&1, :name, "qux"))
        |> ServerState.add_room("another_room", "qux")
        |> ServerState.get_and_clear_notifications()

      assert {:ok, state, _} = CommandExecutor.execute(state, "foo", "join-room spaceship")

      assert [
               %TextBasedFPS.Notification{
                 body: "\e[33mfoo joined the room!\e[0m",
                 created_at: %DateTime{},
                 player_key: "bar"
               }
             ] = state.notifications
    end
  end

  describe "full room" do
    setup %{state: state} do
      %{state: add_full_room(state)}
    end

    test "returns error", %{state: state} do
      assert {:error, _state, message} =
               CommandExecutor.execute(state, "foo", "join-room full-room")

      assert message =~ "This room is full"
    end

    test "does not change anything on the target room", %{state: state} do
      assert {:error, updated_state, _message} =
               CommandExecutor.execute(state, "foo", "join-room full-room")

      assert updated_state.rooms["full-room"] == state.rooms["full-room"]
    end

    test "keeps player out of room", %{state: state} do
      assert {:error, state, _message} =
               CommandExecutor.execute(state, "foo", "join-room full-room")

      assert state.players["foo"].room == nil
    end

    test "doesn't remove player from current room, if player is already in a room", %{
      state: state
    } do
      assert {:ok, state, _message} = CommandExecutor.execute(state, "foo", "join-room spaceship")

      assert {:error, updated_state, _message} =
               CommandExecutor.execute(state, "foo", "join-room full-room")

      assert state.players["foo"].room == "spaceship"
      assert updated_state.rooms["spaceship"] == state.rooms["spaceship"]
    end

    defp add_full_room(state) do
      state = ServerState.add_room(state, "full-room")
      respawn_positions = state.rooms["full-room"].game_map.respawn_positions |> length()

      1..respawn_positions
      |> Enum.reduce(state, fn n, state ->
        state
        |> ServerState.add_player("player-#{n}")
        |> ServerState.join_room!("full-room", "player-#{n}")
      end)
    end
  end

  describe "player already in room" do
    test "returns error if user is already on the same room", %{state: state} do
      assert {:ok, state, _} = CommandExecutor.execute(state, "foo", "join-room spaceship")

      assert {:error, _state, message} =
               CommandExecutor.execute(state, "foo", "join-room spaceship")

      assert message =~ "You're already in this room"
    end

    test "removes player from their previous room", %{state: state} do
      state =
        state
        |> ServerState.add_player("bar")
        |> ServerState.update_player("bar", &Map.put(&1, :name, "bar"))
        |> ServerState.add_room("spaceship", "bar")

      assert {:ok, state, _} = CommandExecutor.execute(state, "foo", "join-room spaceship")
      assert {:ok, state, _} = CommandExecutor.execute(state, "foo", "join-room other")

      assert %{
               rooms: %{
                 "spaceship" => %{
                   players: %{
                     "bar" => %RoomPlayer{}
                   }
                 },
                 "other" => %{
                   players: %{
                     "foo" => %RoomPlayer{}
                   }
                 }
               }
             } = state
    end
  end
end
