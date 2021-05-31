defmodule TextBasedFPS.CLI do
  alias TextBasedFPS.ServerAgent

  def start do
    ServerAgent.start()
    player = ServerAgent.add_player()
    player2 = ServerAgent.add_player()

    ServerAgent.run_command(player, "set-name gui")
    ServerAgent.run_command(player, "join-room a")

    ServerAgent.run_command(player2, "set-name gui2")
    ServerAgent.run_command(player2, "join-room a")

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

  # p1 = ServerAgent.add_player()
  # ServerAgent.run_command(p1, "set-name gui")
  # p2 = ServerAgent.add_player()
  # ServerAgent.run_command(p2, "set-name gui2")
  # p3 = ServerAgent.add_player()
  # ServerAgent.run_command(p3, "set-name gui3")
  # ServerAgent.run_command(p1, "join-room hi")
  # ServerAgent.run_command(p2, "join-room hi")
  # ServerAgent.run_command(p3, "join-room hi")
  # IO.inspect ServerAgent.run_command(p1, "ammo")
  # IO.inspect ServerAgent.run_command(p1, "fire")
  # IO.inspect ServerAgent.run_command(p1, "fire")
  # IO.inspect ServerAgent.run_command(p1, "fire")
  # IO.inspect ServerAgent.run_command(p1, "fire")
  # IO.inspect ServerAgent.run_command(p1, "fire")
  # IO.inspect ServerAgent.run_command(p1, "fire")
  # IO.inspect ServerAgent.run_command(p1, "fire")
  # IO.inspect ServerAgent.run_command(p1, "fire")
  # IO.inspect ServerAgent.run_command(p1, "fire")
  # IO.inspect ServerAgent.run_command(p1, "fire")
  # IO.inspect ServerAgent.run_command(p1, "fire")
  # IO.inspect ServerAgent.run_command(p1, "fire")
  # IO.inspect ServerAgent.run_command(p1, "reload")
  # IO.inspect ServerAgent.run_command(p1, "fire")
  # IO.inspect ServerAgent.run_command(p1, "ammo")
  # IO.inspect ServerAgent.run_command(p1, "reload")
  # IO.inspect ServerAgent.run_command(p1, "ammo")

  # IO.inspect ServerAgent.get_state()

  # {player_key, state} = ServerState.add_player(state)
  # {:ok, state, _} = PlayerCommand.execute(state, player_key, "set-name gui")
  # {:ok, state, _} = PlayerCommand.execute(state, player_key, "join-room hello")

  # {:ok, state, score} = PlayerCommand.execute(state, player_key, "score")
  # {_, state, msg} = PlayerCommand.execute(state, player_key, "respawn")
  # {_, state, msg} = PlayerCommand.execute(state, player_key, "room-list")
  # {_, state, _} = PlayerCommand.execute(state, player_key, "turn around")
  # {_, state, _} = PlayerCommand.execute(state, player_key, "move south")
  # {_, state, _} = PlayerCommand.execute(state, player_key, "move south")
  # {_, state, _} = PlayerCommand.execute(state, player_key, "move")
  # {_, state, msg} = PlayerCommand.execute(state, player_key, "move south")
  # {_, state, msg} = PlayerCommand.execute(state, player_key, "look")
  # IO.inspect msg

  # IO.inspect state
end
