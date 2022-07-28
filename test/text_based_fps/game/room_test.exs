defmodule TextBasedFPS.Game.RoomTest do
  alias TextBasedFPS.Game.{Room, RoomPlayer}
  alias TextBasedFPS.GameMap.{Matrix, Objects}

  use ExUnit.Case, async: true

  test "remove_player/2" do
    room = Room.new("room") |> Room.add_player!("foo") |> Room.add_player!("bar")
    room = Room.remove_player(room, "foo")
    assert Map.has_key?(room.players, "foo") == false

    Enum.with_index(room.game_map.matrix)
    |> Enum.each(fn {row, y} ->
      Enum.with_index(row)
      |> Enum.each(fn {_, x} ->
        assert Matrix.player_at?(room.game_map.matrix, {x, y}, "foo") == false
      end)
    end)
  end

  test "add_object/3" do
    room = Room.new("room") |> Room.add_object({1, 1}, Objects.AmmoPack)
    assert %Objects.AmmoPack{} = Matrix.at(room.game_map.matrix, {1, 1})
  end

  test "add_random_object/2" do
    for _i <- 0..20 do
      room = Room.new("room") |> Room.add_random_object({1, 1})
      assert Matrix.object_at?(room.game_map.matrix, {1, 1}) == true
      assert Matrix.player_at?(room.game_map.matrix, {1, 1}) == false
    end
  end

  describe "respawn_player/2" do
    test "respawns dead player" do
      {:ok, room} =
        Room.new("room")
        |> Room.add_player!("foo")
        |> Room.remove_player_from_map("foo")
        |> Room.update_player("foo", &Map.put(&1, :health, 0))
        |> Room.respawn_player("foo")

      assert room.players["foo"].health == RoomPlayer.max_health()
      assert room.players["foo"].coordinates != nil
      assert room.players["foo"].direction != nil
      assert room.players["foo"].ammo != {0, 0}

      assert Matrix.player_at?(room.game_map.matrix, room.players["foo"].coordinates, "foo") ==
               true
    end

    test "does not respawn player that is already alive" do
      room =
        Room.new("room")
        |> Room.add_player!("foo")
        |> Room.update_player("foo", &Map.put(&1, :health, 90))

      {:error, :player_is_alive} = Room.respawn_player(room, "foo")
      assert room.players["foo"].health == 90
    end
  end

  describe "place_player_at/3" do
    test "moves player to coordinates specified when place is empty" do
      assert {:ok, room, nil} =
               Room.new("room")
               |> Room.add_player!("foo")
               |> Room.place_player_at("foo", {1, 2})

      assert room.players["foo"].coordinates == {1, 2}
      assert Matrix.player_at?(room.game_map.matrix, {1, 2}, "foo") == true
    end

    test "does nothing and returns successfully if player is already there" do
      assert {:ok, room, nil} =
               Room.new("room")
               |> Room.add_player!("foo")
               |> Room.place_player_at("foo", {1, 2})

      assert {:ok, room, nil} = Room.place_player_at(room, "foo", {1, 2})

      assert room.players["foo"].coordinates == {1, 2}
      assert Matrix.player_at?(room.game_map.matrix, {1, 2}, "foo") == true
    end

    test "moves player to coordinates and grabs object if coordinates specified has an object" do
      assert {:ok, room, object_grabbed} =
               Room.new("room")
               |> Room.add_player!("foo")
               |> Room.add_random_object({1, 2})
               |> Room.place_player_at("foo", {1, 2})

      assert Objects.object?(object_grabbed) == true
      assert room.players["foo"].coordinates == {1, 2}
      assert Matrix.player_at?(room.game_map.matrix, {1, 2}, "foo") == true
    end

    test "returns error if coordinates specified have a wall" do
      assert {:error, room} =
               Room.new("room")
               |> Room.add_player!("foo")
               |> Room.place_player_at("foo", {0, 0})

      assert room.players["foo"].coordinates != {0, 0}
      assert Matrix.player_at?(room.game_map.matrix, {0, 0}, "foo") == false
    end

    test "returns error if coordinates specified have another player" do
      assert {:ok, room, nil} =
               Room.new("room")
               |> Room.add_player!("foo")
               |> Room.add_player!("bar")
               |> Room.place_player_at("bar", {1, 2})

      assert {:error, room} = Room.place_player_at(room, "foo", {1, 2})

      assert room.players["foo"].coordinates != {1, 2}
      assert Matrix.player_at?(room.game_map.matrix, {1, 2}, "foo") == false
      assert Matrix.player_at?(room.game_map.matrix, {1, 2}, "bar") == true
    end

    test "returns error if coordinates specified don't exist" do
      assert {:error, room} =
               Room.new("room")
               |> Room.add_player!("foo")
               |> Room.place_player_at("foo", {999, 999})

      assert room.players["foo"].coordinates != {999, 999}
      assert Matrix.player_at?(room.game_map.matrix, {999, 999}, "foo") == false
    end
  end

  describe "remove_player_from_map/2" do
    test "removes the player from the map" do
      room =
        Room.new("room")
        |> Room.add_player!("foo")
        |> Room.remove_player_from_map("foo")

      assert room.players["foo"].coordinates == nil
      assert room.players["foo"].health == 100

      Enum.with_index(room.game_map.matrix)
      |> Enum.each(fn {row, y} ->
        Enum.with_index(row)
        |> Enum.each(fn {_, x} ->
          assert Matrix.player_at?(room.game_map.matrix, {x, y}, "foo") == false
        end)
      end)
    end

    test "does nothing if player is already out of the map" do
      room =
        Room.new("room")
        |> Room.add_player!("foo")
        |> Room.remove_player_from_map("foo")
        # do it twice
        |> Room.remove_player_from_map("foo")

      assert room.players["foo"].coordinates == nil
      assert room.players["foo"].health == 100

      Enum.with_index(room.game_map.matrix)
      |> Enum.each(fn {row, y} ->
        Enum.with_index(row)
        |> Enum.each(fn {_, x} ->
          assert Matrix.player_at?(room.game_map.matrix, {x, y}, "foo") == false
        end)
      end)
    end
  end

  describe "kill_player/2" do
    test "removes the player from the map and changes their health to 0" do
      room =
        Room.new("room")
        |> Room.add_player!("foo")
        |> Room.kill_player("foo")

      assert room.players["foo"].coordinates == nil
      assert room.players["foo"].health == 0

      Enum.with_index(room.game_map.matrix)
      |> Enum.each(fn {row, y} ->
        Enum.with_index(row)
        |> Enum.each(fn {_, x} ->
          assert Matrix.player_at?(room.game_map.matrix, {x, y}, "foo") == false
        end)
      end)
    end
  end

  test "get_player/2" do
    room = Room.new("room") |> Room.add_player!("foo")
    assert %RoomPlayer{player_key: "foo"} = Room.get_player(room, "foo")
    assert Room.get_player(room, "bar") == nil
  end

  describe "update_player/3" do
    test "with updater function" do
      room =
        Room.new("room")
        |> Room.add_player!("foo")
        |> Room.update_player("foo", fn player -> Map.put(player, :health, 50) end)

      assert room.players["foo"].health == 50
    end

    test "with updated player" do
      room = Room.new("room") |> Room.add_player!("foo")
      updated_player = Map.put(room.players["foo"], :health, 50)
      updated_room = Room.update_player(room, "foo", updated_player)

      assert updated_room.players["foo"].health == 50
    end
  end

  describe "validate_name/1" do
    test "does not allow empty name" do
      assert Room.validate_name("") == {:error, :empty}
    end

    test "does not allow name with more than 20 chars" do
      allowed_name = "12345678901234567890"
      large_name = "123456789012345678901"
      assert Room.validate_name(allowed_name) == :ok
      assert Room.validate_name(large_name) == {:error, :too_large}
    end

    test "only allows names with letters, numbers and hyphens" do
      assert Room.validate_name("abc") == :ok
      assert Room.validate_name("ABC") == :ok
      assert Room.validate_name("123") == :ok
      assert Room.validate_name("abc-123") == :ok
      assert Room.validate_name("abc 123") == {:error, :invalid_chars}
      assert Room.validate_name("aaa!") == {:error, :invalid_chars}
      assert Room.validate_name("aaa_") == {:error, :invalid_chars}
      assert Room.validate_name("ááá") == {:error, :invalid_chars}
    end
  end
end
