defmodule TextBasedFPS.GameMap do
  @type t :: %TextBasedFPS.GameMap{
    matrix: TextBasedFPS.GameMap.Matrix.t,
    respawn_positions: list(TextBasedFPS.GameMap.RespawnPosition.t)
  }

  defstruct [:matrix, :respawn_positions]

  @spec new() :: t
  def new do
    text_representation = File.read!(map_file_path())
    TextBasedFPS.GameMap.Builder.build(text_representation)
  end

  def update_matrix(game_map, fun) do
    matrix = game_map.matrix
    Map.put(game_map, :matrix, fun.(matrix))
  end

  defp map_file_path do
    Path.join(:code.priv_dir(:text_based_fps), "map.txt")
  end
end
