defmodule TextBasedFPS.Game.CommandExecutorTest do
  use ExUnit.Case, async: true

  alias TextBasedFPS.Game.{CommandExecutor, Player}
  alias TextBasedFPS.Process

  import Mox

  setup :verify_on_exit!

  describe "execute/4" do
    test "executes command and updates 'last_command_at' of executor" do
      defmodule MyTestCommand do
        def execute(player, command_arg) do
          assert command_arg == "hello world"
          assert player.key == "foo"
          assert %DateTime{} = player.last_command_at
          {:ok, "returned message"}
        end
      end

      expect(Process.Players.Mock, :update_player, fn player_key, fun ->
        assert player_key == "foo"
        fun.(Player.new("foo"))
      end)

      commands = %{
        "my-command" => MyTestCommand
      }

      assert {:ok, "returned message"} =
               CommandExecutor.execute("foo", "my-command hello world", commands)
    end

    test "returns error when player does not exist" do
      commands = %{"my-command" => DummyCommand}

      expect(Process.Players.Mock, :update_player, fn _, _ -> nil end)

      assert {:error, error_message} =
               CommandExecutor.execute("foo", "my-command hello world", commands)

      assert error_message =~ "session has expired"
    end

    test "returns error when command specified does not exist" do
      commands = %{}

      expect(Process.Players.Mock, :update_player, fn player_key, fun ->
        fun.(Player.new(player_key))
      end)

      assert {:error, "Command not found"} =
               CommandExecutor.execute("foo", "my-command hello world", commands)
    end
  end

  defmodule DummyCommand do
    def execute(_, _), do: {:ok, nil}
  end
end
