defmodule TextBasedFPS.CLI do
  alias TextBasedFPS.ServerAgent

  def start do
    ServerAgent.start_link([])

    player = ServerAgent.add_player()
    player2 = ServerAgent.add_player()

    ServerAgent.run_command(player, "set-name John")
    ServerAgent.run_command(player, "join-room spaceship")

    ServerAgent.run_command(player2, "set-name Jane")
    ServerAgent.run_command(player2, "join-room spaceship")

    receive_command(0, [player, player2])
  end

  defp receive_command(current_player_idx, players) do
    command = IO.gets(IO.ANSI.reset() <> "> ") |> String.trim()

    [command_name | command_arg] = String.split(command, " ")
    command_arg = String.trim(Enum.join(command_arg, " "))

    current_player = Enum.at(players, current_player_idx)

    case command_name do
      "add-player" ->
        new_player = ServerAgent.add_player()
        IO.puts "Switching to new player #{new_player}..."
        receive_command(length(players), players ++ [new_player])

      "switch-player" ->
        {player_idx, ""} = Integer.parse(command_arg)
        IO.puts "Switching to player #{Enum.at(players, player_idx)}..."
        receive_command(player_idx, players)

      "view-state" ->
        IO.inspect ServerAgent.get_state()
        receive_command(current_player_idx, players)

      "remove-player" ->
        ServerAgent.remove_player(current_player)
        receive_command(current_player_idx, players)

      _ ->
        result = ServerAgent.run_command(current_player, command)
        print_result(result)
        receive_command(current_player_idx, players)
    end
  end

  defp print_result(result) do
    case result do
      {:ok, msg} -> IO.puts(msg)
      {:error, msg} -> IO.puts(IO.ANSI.red() <> msg)
    end
  end
end
