defmodule TextBasedFPS.Game.CommandExecutorTest do
  use ExUnit.Case, async: true

  alias TextBasedFPS.Game.{CommandExecutor, ServerState}

  describe "execute/4" do
    test "executes command and updates 'last_command_at' of executor" do
      defmodule MyTestCommand do
        def execute(state, player, command_arg) do
          assert command_arg == "hello world"
          assert player.key == "foo"
          assert %ServerState{} = state
          {:ok, state, "returned message"}
        end
      end

      commands = %{
        "my-command" => TextBasedFPS.Game.CommandExecutorTest.MyTestCommand
      }

      assert {:ok, updated_state, "returned message"} =
               ServerState.new()
               |> ServerState.add_player("foo")
               |> CommandExecutor.execute("foo", "my-command hello world", commands)

      assert updated_state.players["foo"].last_command_at != nil
    end

    test "returns error if player does not exist" do
      commands = %{"my-command" => TextBasedFPS.Game.CommandExecutorTest.DummyCommand}
      state = ServerState.new()

      assert {:error, ^state, error_message} =
               CommandExecutor.execute(state, "foo", "my-command hello world", commands)

      assert error_message =~ "session has expired"
    end

    test "returns error if command does not exist" do
      commands = %{}

      assert {:error, _state, "Command not found"} =
               ServerState.new()
               |> ServerState.add_player("foo")
               |> CommandExecutor.execute("foo", "my-command hello world", commands)
    end
  end

  defmodule DummyCommand do
    def execute(state, _, _), do: {:ok, state, nil}
  end
end
