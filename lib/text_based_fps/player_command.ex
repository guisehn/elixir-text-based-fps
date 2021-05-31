defmodule TextBasedFPS.PlayerCommand do
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

  def execute(state, player_key, command) do
    player = ServerState.get_player(state, player_key)

    [command_name | command_arg] = String.split(command, " ")
    command = @commands[command_name]
    command_arg = String.trim(Enum.join(command_arg, " "))

    state
    |> ServerState.update_player(player_key, &Player.touch/1)
    |> execute(player, command, command_arg)
  end

  defp execute(state, nil, _command, _command_arg), do: {:error, state, "Player not found"}
  defp execute(state, _player, nil, _command_arg), do: {:error, state, "Command not found"}
  defp execute(state, player, command, command_arg), do: command.execute(state, player, command_arg)
end
