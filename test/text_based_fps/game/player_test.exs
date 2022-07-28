defmodule TextBasedFPS.Game.PlayerTest do
  use ExUnit.Case, async: true

  alias TextBasedFPS.Game.Player

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
      assert Player.validate_name("") == {:error, :empty}
    end

    test "does not allow name with more than 20 chars" do
      allowed_name = "12345678901234567890"
      large_name = "123456789012345678901"
      assert Player.validate_name(allowed_name) == :ok
      assert Player.validate_name(large_name) == {:error, :too_large}
    end

    test "only allows names with letters, numbers and hyphens" do
      assert Player.validate_name("abc") == :ok
      assert Player.validate_name("ABC") == :ok
      assert Player.validate_name("123") == :ok
      assert Player.validate_name("abc-123") == :ok
      assert Player.validate_name("abc 123") == {:error, :invalid_chars}
      assert Player.validate_name("aaa!") == {:error, :invalid_chars}
      assert Player.validate_name("aaa_") == {:error, :invalid_chars}
      assert Player.validate_name("ááá") == {:error, :invalid_chars}
    end
  end
end
