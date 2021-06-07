defmodule TextBasedFPS.CommandExecutorTest do
  alias TextBasedFPS.CommandExecutor
  alias TextBasedFPS.ServerState

  use ExUnit.Case, async: true

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
        "my-command" => TextBasedFPS.CommandExecutorTest.MyTestCommand
      }

      {_, server_state} = ServerState.new() |> ServerState.add_player("foo")

      assert {:ok, updated_server_state, "returned message"} =
        CommandExecutor.execute(server_state, "foo", "my-command hello world", commands)

      assert updated_server_state.players["foo"].last_command_at != nil
    end

    test "returns error if player does not exist" do
      commands = %{"my-command" => TextBasedFPS.CommandExecutorTest.DummyCommand}
      server_state = ServerState.new()

      assert {:error, _server_state, error_message} =
        CommandExecutor.execute(server_state, "foo", "my-command hello world", commands)

      assert error_message =~ "session has expired"
    end

    test "returns error if command does not exist" do
      commands = %{}

      {_, server_state} = ServerState.new() |> ServerState.add_player("foo")

      assert {:error, _server_state, "Command not found"} =
        CommandExecutor.execute(server_state, "foo", "my-command hello world", commands)
    end
  end

  defmodule DummyCommand do
    def execute(state, _, _), do: {:ok, state, nil}
  end
end
