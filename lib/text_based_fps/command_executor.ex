defmodule TextBasedFPS.CommandExecutor do
  alias TextBasedFPS.{Player, PlayerCommand}
  alias TextBasedFPS.Process.Players

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

  @spec execute(Player.key_t(), String.t(), Map.t()) ::
          {:ok, String.t() | nil} | {:error, String.t()}
  def execute(player_key, command_text, commands \\ @commands) do
    player = Players.update_player(player_key, &Player.touch/1)
    {command, command_arg} = parse_command(command_text, commands)
    execute_command_with_args(player, command, command_arg)
  end

  defp parse_command(command_text, commands) do
    [command_name | command_arg] = String.split(command_text, " ")
    command = commands[command_name]
    command_arg = String.trim(Enum.join(command_arg, " "))
    {command, command_arg}
  end

  defp execute_command_with_args(nil, _command, _command_arg) do
    {:error, "Your session has expired. Reload the page to play."}
  end

  defp execute_command_with_args(_player, nil, _command_arg) do
    {:error, "Command not found"}
  end

  defp execute_command_with_args(player, command, command_arg) do
    command.execute(player, command_arg)
  end
end
