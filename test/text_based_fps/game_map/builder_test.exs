defmodule TextBasedFPS.GameMap.BuilderTest do
  alias TextBasedFPS.GameMap.Builder

  use ExUnit.Case, async: true

  test "get_respawn_positions/1" do
    matrix = [
      [:"#", :"#", :"#", :"#", :"#", :"#", :"#", :"#", :"#", :"#"],
      [:"#", :" ", :"N", :"S", :"W", :"E", :" ", :".", :" ", :"#"],
      [:"#", :"#", :"#", :"#", :"#", :"#", :"#", :"#", :"#", :"#"]
    ]

    respawn_positions = Builder.get_respawn_positions(matrix)

    assert respawn_positions == [
      %TextBasedFPS.GameMap.RespawnPosition{coordinates: {2, 1}, direction: :north},
      %TextBasedFPS.GameMap.RespawnPosition{coordinates: {3, 1}, direction: :south},
      %TextBasedFPS.GameMap.RespawnPosition{coordinates: {4, 1}, direction: :west},
      %TextBasedFPS.GameMap.RespawnPosition{coordinates: {5, 1}, direction: :east}
    ]
  end

  test "build/1" do
    text_representation = """

##########
# NSWE . #
##########

"""

    game_map = Builder.build(text_representation)

    assert game_map == %TextBasedFPS.GameMap{
      matrix: [
        [:"#", :"#", :"#", :"#", :"#", :"#", :"#", :"#", :"#", :"#"],
        [:"#", :" ", :" ", :" ", :" ", :" ", :" ", :" ", :" ", :"#"],
        [:"#", :"#", :"#", :"#", :"#", :"#", :"#", :"#", :"#", :"#"]
      ],
      respawn_positions: [
        %TextBasedFPS.GameMap.RespawnPosition{coordinates: {2, 1}, direction: :north},
        %TextBasedFPS.GameMap.RespawnPosition{coordinates: {3, 1}, direction: :south},
        %TextBasedFPS.GameMap.RespawnPosition{coordinates: {4, 1}, direction: :west},
        %TextBasedFPS.GameMap.RespawnPosition{coordinates: {5, 1}, direction: :east}
      ]
    }
  end
end
