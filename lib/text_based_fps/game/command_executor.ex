defmodule TextBasedFPS.Game.CommandExecutor do
  alias TextBasedFPS.{Game, GameState}
  alias TextBasedFPS.Game.Command

  @commands %{
    "room-list" => Command.RoomList,
    "join-room" => Command.JoinRoom,
    "leave-room" => Command.LeaveRoom,
    "set-name" => Command.SetName,
    "health" => Command.Health,
    "ammo" => Command.Ammo,
    "reload" => Command.Reload,
    "score" => Command.Score,
    "respawn" => Command.Respawn,
    "turn" => Command.Turn,
    "move" => Command.Move,
    "look" => Command.Look,
    "fire" => Command.Fire
  }

  @spec execute(Game.Player.key_t(), String.t(), Map.t()) ::
          {:ok, String.t() | nil} | {:error, String.t()}
  def execute(player_key, command_text, commands \\ @commands) do
    player = GameState.update_player(player_key, &Game.Player.touch/1)
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
