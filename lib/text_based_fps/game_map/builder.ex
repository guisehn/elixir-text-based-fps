defmodule TextBasedFPS.GameMap.Builder do
  alias TextBasedFPS.GameMap
  alias TextBasedFPS.GameMap.RespawnPosition
  alias TextBasedFPS.GameMap.TextParser
  alias TextBasedFPS.Direction

  @spec build(String.t) :: GameMap.t
  def build(text_representation) do
    raw_matrix = TextParser.parse(text_representation)
    respawn_positions = get_respawn_positions(raw_matrix)
    matrix = GameMap.Matrix.clean(raw_matrix)

    %GameMap{
      matrix: matrix,
      respawn_positions: respawn_positions
    }
  end

  @spec get_respawn_positions(GameMap.Matrix.t) :: list(RespawnPosition.t)
  def get_respawn_positions(matrix) do
    matrix
    |> Stream.with_index
    |> Enum.map(fn {line, y} ->
      line
      |> Stream.with_index
      |> Stream.filter(fn {position, _x} -> respawn_position?(position) end)
      |> Enum.map(fn {direction, x} ->
        %RespawnPosition{coordinates: {x, y}, direction: Direction.from_respawn_position_char(direction)}
      end)
    end)
    |> List.flatten
  end

  defp respawn_position?(position), do: Enum.member?(~w(N S W E)a, position)
end
