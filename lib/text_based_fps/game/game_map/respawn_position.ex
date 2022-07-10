defmodule TextBasedFPS.GameMap.RespawnPosition do
  alias TextBasedFPS.{Direction, Room}
  alias TextBasedFPS.GameMap.{Coordinates, Matrix, RespawnPosition}

  @type t :: %RespawnPosition{
          coordinates: Coordinates.t(),
          direction: Direction.t()
        }

  defstruct [:coordinates, :direction]

  @spec find_respawn_position(Room.t()) :: t
  def find_respawn_position(room) do
    candidates = Enum.shuffle(empty_respawn_positions(room))

    safe_respawn_position =
      Enum.find(candidates, fn %{coordinates: coordinates} ->
        safe_coordinates?(room.game_map.matrix, coordinates)
      end)

    safe_respawn_position || List.first(candidates)
  end

  defp empty_respawn_positions(room) do
    Enum.filter(
      room.game_map.respawn_positions,
      fn %{coordinates: coordinates} ->
        !Matrix.player_at?(room.game_map.matrix, coordinates)
      end
    )
  end

  @spec safe_coordinates?(Matrix.t(), Coordinates.t()) :: boolean
  def safe_coordinates?(matrix, coordinates) do
    Enum.all?(
      Direction.all(),
      fn direction -> safe_coordinates?(matrix, coordinates, direction) end
    )
  end

  defp safe_coordinates?(matrix, coordinates, direction) do
    Matrix.iterate_towards(
      matrix,
      coordinates,
      direction,
      # start considering it safe
      true,
      fn coordinates, _ ->
        cond do
          # found a wall? stop it and consider it safe
          # if there's an enemy in this direction, they're behind a wall so they can't see you
          Matrix.wall_at?(matrix, coordinates) ->
            {:stop, true}

          # found an enemy? stop it and consider it unsafe
          Matrix.player_at?(matrix, coordinates) ->
            {:stop, false}

          # nothing found at this coordinates? then it's safe so far...
          # continue checking the next coordinates
          true ->
            {:continue, true}
        end
      end
    )
  end
end
