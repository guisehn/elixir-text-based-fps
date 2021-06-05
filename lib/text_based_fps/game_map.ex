defmodule TextBasedFPS.GameMap do
  defstruct [:matrix, :respawn_positions]

  def build do
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
