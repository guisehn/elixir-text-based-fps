defmodule TextBasedFPS.PlayerCommand.Look do
  alias TextBasedFPS.PlayerCommand
  alias TextBasedFPS.GameMap
  alias TextBasedFPS.Room

  import TextBasedFPS.PlayerCommand.Util

  @behaviour PlayerCommand

  @impl true
  def execute(state, player, _) do
    require_alive_player(state, player, fn room ->
      {:ok, state, generate_vision(player, room)}
    end)
  end

  defp generate_vision(player, room) do
    room_player = Room.get_player(room, player.key)
    game_matrix = room.game_map.matrix

    vision_matrix = GameMap.Matrix.iterate_towards(
      room.game_map.matrix,
      room_player.coordinates,
      room_player.direction,
      # Generate the view based on a clean version of the map showing only walls and empty spaces
      GameMap.Matrix.clean(game_matrix),
      fn coordinates, vision_matrix ->
        cond do
          # Player can't see behind walls. If we find one, stop it.
          GameMap.Matrix.wall_at?(game_matrix, coordinates) ->
            {:stop, vision_matrix}

          GameMap.Matrix.object_at?(game_matrix, coordinates) ->
            object = GameMap.Matrix.at(game_matrix, coordinates)
            {:continue, GameMap.Matrix.set(vision_matrix, coordinates, display_object(object, room))}

          true ->
            {:continue, vision_matrix}
        end
      end
    )

    GameMap.Matrix.set(vision_matrix, room_player.coordinates, display_me(room_player, room))
    |> Stream.map(fn line -> Enum.join(line, " ") end)
    |> Enum.join("\n")
  end

  defp display_object(object, room) do
    IO.ANSI.red() <> GameMap.Object.symbol(object, room) <> IO.ANSI.reset()
  end

  defp display_me(me, room) do
    player_object = GameMap.Objects.Player.new(me.player_key)
    IO.ANSI.green() <> GameMap.Object.symbol(player_object, room) <> IO.ANSI.reset()
  end
end
