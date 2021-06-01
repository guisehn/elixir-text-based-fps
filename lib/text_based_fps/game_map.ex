defmodule TextBasedFPS.GameMap do
  @map_file_path "priv/map.txt"
  @absolute_map_file_path Path.expand(@map_file_path, File.cwd!)

  defstruct [:matrix, :respawn_positions]

  def build do
    text_representation = File.read!(@absolute_map_file_path)
    TextBasedFPS.GameMap.Builder.build(text_representation)
  end

  def update_matrix(game_map, fun) do
    matrix = game_map.matrix
    Map.put(game_map, :matrix, fun.(matrix))
  end
end
