defmodule TextBasedFPS.PlayerTest do
  alias TextBasedFPS.Player
  alias TextBasedFPS.ServerState

  use ExUnit.Case, async: true

  describe "touch/1" do
    test "updates 'last_command_at' of player" do
      earlier = DateTime.utc_now() |> DateTime.add(-5, :second)
      player = %Player{key: "foo", last_command_at: earlier}
      updated_player = Player.touch(player)
      assert DateTime.compare(updated_player.last_command_at, earlier) == :gt
    end
  end

  describe "validate_name/2" do
    test "does not allow empty name" do
      assert Player.validate_name(ServerState.new(), "") == {:error, :empty}
    end

    test "does not allow name with more than 20 chars" do
      allowed_name = "12345678901234567890"
      large_name = "123456789012345678901"
      assert Player.validate_name(ServerState.new(), allowed_name) == :ok
      assert Player.validate_name(ServerState.new(), large_name) == {:error, :too_large}
    end

    test "only allows names with letters, numbers and hyphens" do
      assert Player.validate_name(ServerState.new(), "abc") == :ok
      assert Player.validate_name(ServerState.new(), "ABC") == :ok
      assert Player.validate_name(ServerState.new(), "123") == :ok
      assert Player.validate_name(ServerState.new(), "abc-123") == :ok
      assert Player.validate_name(ServerState.new(), "abc 123") == {:error, :invalid_chars}
      assert Player.validate_name(ServerState.new(), "aaa!") == {:error, :invalid_chars}
      assert Player.validate_name(ServerState.new(), "aaa_") == {:error, :invalid_chars}
      assert Player.validate_name(ServerState.new(), "ááá") == {:error, :invalid_chars}
    end

    test "does not allow using name that is already in use on the server" do
      state =
        ServerState.new()
        |> ServerState.add_player("foo")
        |> ServerState.update_player("foo", &Map.put(&1, :name, "foo"))

      assert Player.validate_name(state, "foo") == {:error, :already_in_use}
      assert Player.validate_name(state, "bar") == :ok
    end
  end
end
