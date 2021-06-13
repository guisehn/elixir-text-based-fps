defmodule TextBasedFPS.PlayerCommand.Look do
  alias TextBasedFPS.GameMap
  alias TextBasedFPS.PlayerCommand
  alias TextBasedFPS.Room
  alias TextBasedFPS.Text

  import TextBasedFPS.CommandHelper

  @behaviour PlayerCommand

  @impl true
  def execute(state, player, _) do
    with {:ok, room} <- require_alive_player(state, player) do
      {:ok, state, generate_vision(player, room)}
    end
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

          # Object or enemy
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
    color = GameMap.Object.color(object)
    symbol = GameMap.Object.symbol(object, room)
    Text.paint(symbol, color)
  end

  defp display_me(me, room) do
    player_object = GameMap.Objects.Player.new(me.player_key)
    Text.success(GameMap.Object.symbol(player_object, room))
  end
end
