defmodule TextBasedFPS.GameMap.RespawnPosition do
  alias TextBasedFPS.Direction
  alias TextBasedFPS.GameMap.Coordinates
  alias TextBasedFPS.GameMap.Matrix
  alias TextBasedFPS.Room

  @type t :: %TextBasedFPS.GameMap.RespawnPosition {
    coordinates: Coordinates.t,
    direction: Direction.t
  }

  defstruct [:coordinates, :direction]

  @spec find_respawn_position(Room.t) :: t
  def find_respawn_position(room) do
    candidates = Enum.shuffle(empty_respawn_positions(room))
    safe_respawn_position = Enum.find(candidates, fn %{coordinates: coordinates} ->
      safe_coordinates?(room, coordinates)
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

  @spec safe_coordinates?(Room.t, Coordinates.t) :: boolean
  def safe_coordinates?(room, coordinates) do
    Enum.all?(
      Direction.all(),
      fn direction -> safe_coordinates?(room, coordinates, direction) end
    )
  end
  def safe_coordinates?(room, coordinates, direction) do
    Matrix.iterate_towards(
      room.game_map.matrix,
      coordinates,
      direction,
      true,
      fn coordinates, _ ->
        case Matrix.player_at?(room.game_map.matrix, coordinates) do
          true -> {:stop, false} # another player found? then it's not safe
          false -> {:continue, true}
        end
      end
    )
  end
end
