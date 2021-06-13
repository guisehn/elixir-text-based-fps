defmodule TextBasedFPS.GameMap.RespawnPositionTest do
  alias TextBasedFPS.GameMap
  alias TextBasedFPS.GameMap.RespawnPosition

  use ExUnit.Case, async: true

  setup do
    map_text_representation = """
    ###########
    #         #
    #    #    #
    #         #
    #   # #   #
    # #  N  # #
    #   # #   #
    #         #
    #    #    #
    #         #
    ###########
    """

    %{matrix: matrix} = GameMap.Builder.build(map_text_representation)
    # coordinates indicated by the N on the map text representation
    coordinates_to_check = {5, 5}

    %{
      matrix: matrix,
      coordinates_to_check: coordinates_to_check
    }
  end

  defp place_enemy_at(matrix, {x, y}) do
    GameMap.Matrix.set(matrix, {x, y}, GameMap.Objects.Player.new("enemy"))
  end

  describe "safe_coordinates?/2" do
    test "north", context do
      # enemy behind a wall: safe
      matrix = place_enemy_at(context.matrix, {5, 1})
      assert RespawnPosition.safe_coordinates?(matrix, context.coordinates_to_check) == true

      # enemy not behind a wall: not safe
      matrix = place_enemy_at(context.matrix, {5, 3})
      assert RespawnPosition.safe_coordinates?(matrix, context.coordinates_to_check) == false
    end

    test "south", context do
      # enemy behind a wall: safe
      matrix = place_enemy_at(context.matrix, {5, 9})
      assert RespawnPosition.safe_coordinates?(matrix, context.coordinates_to_check) == true

      # enemy not behind a wall: unsafe
      matrix = place_enemy_at(context.matrix, {5, 7})
      assert RespawnPosition.safe_coordinates?(matrix, context.coordinates_to_check) == false
    end

    test "west", context do
      # enemy behind a wall: safe
      matrix = place_enemy_at(context.matrix, {1, 5})
      assert RespawnPosition.safe_coordinates?(matrix, context.coordinates_to_check) == true

      # enemy not behind a wall: unsafe
      matrix = place_enemy_at(context.matrix, {3, 5})
      assert RespawnPosition.safe_coordinates?(matrix, context.coordinates_to_check) == false
    end

    test "east", context do
      # enemy behind a wall: safe
      matrix = place_enemy_at(context.matrix, {9, 5})
      assert RespawnPosition.safe_coordinates?(matrix, context.coordinates_to_check) == true

      # enemy not behind a wall: unsafe
      matrix = place_enemy_at(context.matrix, {7, 5})
      assert RespawnPosition.safe_coordinates?(matrix, context.coordinates_to_check) == false
    end

    test "multi-direction", context do
      # all enemies behind walls: safe
      matrix =
        context.matrix
        |> place_enemy_at({5, 1})
        |> place_enemy_at({5, 9})
        |> place_enemy_at({1, 5})
        |> place_enemy_at({5, 9})

      assert RespawnPosition.safe_coordinates?(matrix, context.coordinates_to_check) == true

      # at least one enemy with no wall in between: not safe
      matrix =
        context.matrix
        |> place_enemy_at({5, 1})
        |> place_enemy_at({5, 9})
        # this one
        |> place_enemy_at({3, 5})
        |> place_enemy_at({9, 5})

      assert RespawnPosition.safe_coordinates?(matrix, context.coordinates_to_check) == false
    end
  end
end
