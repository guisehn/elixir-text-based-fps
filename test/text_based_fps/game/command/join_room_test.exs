defmodule TextBasedFPS.Game.Command.JoinRoomTest do
  use TextBasedFPS.GameCase, async: true

  alias TextBasedFPS.Game.{CommandExecutor, RoomPlayer}
  alias TextBasedFPS.Process

  setup do
    Process.Players.add_player("foo")
    Process.Players.update_player("foo", &%{&1 | name: "foo"})

    :ok
  end

  describe "player requirements" do
    test "requires player to have a name" do
      Process.Players.update_player("foo", &%{&1 | name: nil})

      assert {:error, message} = CommandExecutor.execute("foo", "join-room spaceship")
      assert message =~ "You need to have a name before joining a room"
    end
  end

  describe "unexisting room" do
    test "creates room and adds player to it if room doesn't exist" do
      assert {:ok, message} = CommandExecutor.execute("foo", "join-room spaceship")
      assert message =~ "You're now on spaceship"

      assert %{players: %{"foo" => %RoomPlayer{}}} = Process.Room.get("spaceship")
    end

    test "validates room name" do
      assert {:error, message} = CommandExecutor.execute("foo", "join-room !!!")
      assert message =~ "Room name can only contain letters, numbers and hyphens"
    end
  end

  describe "existing room" do
    setup [:setup_existing_room]

    defp setup_existing_room(_) do
      join_room("bar", "spaceship")
      Process.Players.update_player("bar", &%{&1 | name: "bar"})
      :ok
    end

    test "adds player to existing room, notifying users on the room" do
      expect_notification(fn player_key, msg ->
        assert player_key == "bar"
        assert msg == "\e[33mfoo joined the room!\e[0m"
        :ok
      end)

      assert {:ok, message} = CommandExecutor.execute("foo", "join-room spaceship")
      assert message =~ "You're now on spaceship"

      assert %{
               players: %{
                 "foo" => %RoomPlayer{},
                 "bar" => %RoomPlayer{}
               }
             } = Process.Room.get("spaceship")
    end
  end

  describe "full room" do
    setup [:create_full_room]

    defp create_full_room(_) do
      Process.RoomSupervisor.add_room(name: "full-room")
      respawn_positions = length(Process.Room.get("full-room").game_map.respawn_positions)
      for i <- 1..respawn_positions, do: join_room("player-#{i}", "full-room")
      :ok
    end

    test "returns error" do
      assert {:error, message} = CommandExecutor.execute("foo", "join-room full-room")
      assert message =~ "This room is full"
    end

    test "does not change anything on the target room" do
      room_before = Process.Room.get("full-room")
      assert {:error, _message} = CommandExecutor.execute("foo", "join-room full-room")
      room_after = Process.Room.get("full-room")

      assert room_before == room_after
    end

    test "keeps player room as nil" do
      assert {:error, _message} = CommandExecutor.execute("foo", "join-room full-room")
      assert Process.Players.get_player("foo").room == nil
    end
  end

  describe "player already in room" do
    test "returns error if user is already on the same room" do
      assert {:ok, _} = CommandExecutor.execute("foo", "join-room spaceship")
      assert {:error, message} = CommandExecutor.execute("foo", "join-room spaceship")
      assert message =~ "You're already in this room"
    end

    test "removes player from their previous room" do
      Process.Players.add_player("bar")
      Process.Players.update_player("bar", &%{&1 | name: "bar"})
      Process.RoomSupervisor.add_room(name: "spaceship", first_player_key: "bar")

      expect_notifications(2)

      assert {:ok, _} = CommandExecutor.execute("foo", "join-room spaceship")
      assert {:ok, _} = CommandExecutor.execute("foo", "join-room other")

      assert %{"bar" => %RoomPlayer{}} = Process.Room.get("spaceship").players
      assert %{"foo" => %RoomPlayer{}} = Process.Room.get("other").players
    end
  end
end
