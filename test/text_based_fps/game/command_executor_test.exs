defmodule TextBasedFPS.Game.CommandExecutorTest do
  use TextBasedFPS.GameCase, async: true

  alias TextBasedFPS.Game.CommandExecutor
  alias TextBasedFPS.GameState

  describe "execute/3" do
    test "executes command and updates 'last_command_at' of executor" do
      defmodule MyTestCommand do
        def execute(player, command_arg) do
          assert command_arg == "hello world"
          assert player.key == "foo"
          assert %DateTime{} = player.last_command_at
          {:ok, "returned message"}
        end
      end

      commands = %{
        "my-command" => MyTestCommand
      }

      GameState.add_player("foo")

      assert {:ok, "returned message"} =
               CommandExecutor.execute("foo", "my-command hello world", commands)
    end

    test "returns error when player does not exist" do
      commands = %{"my-command" => DummyCommand}

      assert {:error, error_message} =
               CommandExecutor.execute("foo", "my-command hello world", commands)

      assert error_message =~ "session has expired"
    end

    test "returns error when command specified does not exist" do
      commands = %{}

      GameState.add_player("foo")

      assert {:error, "Command not found"} =
               CommandExecutor.execute("foo", "my-command hello world", commands)
    end
  end

  defmodule DummyCommand do
    def execute(_, _), do: {:ok, nil}
  end
end
