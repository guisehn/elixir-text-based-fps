defmodule TextBasedFPS.CommandExecutor do
  alias TextBasedFPS.Player
  alias TextBasedFPS.PlayerCommand
  alias TextBasedFPS.ServerState

  @commands %{
    "room-list" => PlayerCommand.RoomList,
    "join-room" => PlayerCommand.JoinRoom,
    "leave-room" => PlayerCommand.LeaveRoom,
    "set-name" => PlayerCommand.SetName,
    "health" => PlayerCommand.Health,
    "ammo" => PlayerCommand.Ammo,
    "reload" => PlayerCommand.Reload,
    "score" => PlayerCommand.Score,
    "respawn" => PlayerCommand.Respawn,
    "turn" => PlayerCommand.Turn,
    "move" => PlayerCommand.Move,
    "look" => PlayerCommand.Look,
    "fire" => PlayerCommand.Fire
  }

  @spec execute(ServerState.t, Player.key_t, String.t, Map.t) :: {:ok, ServerState.t, String.t | nil} | {:error, ServerState.t, String.t}
  def execute(state, player_key, command_text, commands \\ @commands) do
    state = ServerState.update_player(state, player_key, &Player.touch/1)
    player = ServerState.get_player(state, player_key)

    {command, command_arg} = parse_command(command_text, commands)
    execute_command_with_args(state, player, command, command_arg)
  end

  defp parse_command(command_text, commands) do
    [command_name | command_arg] = String.split(command_text, " ")
    command = commands[command_name]
    command_arg = String.trim(Enum.join(command_arg, " "))
    {command, command_arg}
  end

  defp execute_command_with_args(state, nil, _command, _command_arg) do
    {:error, state, "Your session has expired. Reload the page to play."}
  end
  defp execute_command_with_args(state, _player, nil, _command_arg) do
    {:error, state, "Command not found"}
  end
  defp execute_command_with_args(state, player, command, command_arg) do
    command.execute(state, player, command_arg)
  end
end
