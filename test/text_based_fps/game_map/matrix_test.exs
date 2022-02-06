defmodule TextBasedFPS.GameMap.MatrixTest do
  alias TextBasedFPS.GameMap.Matrix
  alias TextBasedFPS.GameMap.Objects

  use ExUnit.Case, async: true

  describe "set/3" do
    test "sets the value at the given coordinates" do
      matrix = [
        [:" ", :" "],
        [:" ", :" "]
      ]

      assert Matrix.set(matrix, {0, 0}, :E) == [[:E, :" "], [:" ", :" "]]
      assert Matrix.set(matrix, {0, 1}, :E) == [[:" ", :" "], [:E, :" "]]
      assert Matrix.set(matrix, {1, 0}, :E) == [[:" ", :E], [:" ", :" "]]
      assert Matrix.set(matrix, {1, 1}, :E) == [[:" ", :" "], [:" ", :E]]
    end
  end

  describe "clear/2" do
    test "clears the coordinates given" do
      matrix = [
        [:A, :B],
        [:C, :D]
      ]

      assert Matrix.clear(matrix, {0, 0}) == [[:" ", :B], [:C, :D]]
      assert Matrix.clear(matrix, {0, 1}) == [[:A, :B], [:" ", :D]]
      assert Matrix.clear(matrix, {1, 0}) == [[:A, :" "], [:C, :D]]
      assert Matrix.clear(matrix, {1, 1}) == [[:A, :B], [:C, :" "]]
    end
  end

  describe "has?/2" do
    test "returns true if the coordinate exists" do
      matrix = [
        [:" ", :" "],
        [:" ", :" "]
      ]

      assert Matrix.has?(matrix, {0, 0}) == true
      assert Matrix.has?(matrix, {0, 1}) == true
      assert Matrix.has?(matrix, {1, 0}) == true
      assert Matrix.has?(matrix, {1, 1}) == true
    end

    test "returns false if the coordinates don't exist" do
      matrix = [
        [:" ", :" "],
        [:" ", :" "]
      ]

      assert Matrix.has?(matrix, {0, 2}) == false
      assert Matrix.has?(matrix, {2, 0}) == false
    end
  end

  describe "wall_at?/2" do
    test "returns true if the coordinates have a wall, and false if it's not a wall" do
      matrix = [
        [:"#", :" "],
        [:" ", :"#"]
      ]

      assert Matrix.wall_at?(matrix, {0, 0}) == true
      assert Matrix.wall_at?(matrix, {0, 1}) == false
      assert Matrix.wall_at?(matrix, {1, 0}) == false
      assert Matrix.wall_at?(matrix, {1, 1}) == true
    end
  end

  describe "object_at/2" do
    test "returns the object at the given coordinates, or nil if it's not an object" do
      matrix = [
        [:"#", Objects.AmmoPack.new()],
        [Objects.HealthPack.new(), Objects.Player.new("foo")],
        [:" ", :" "]
      ]

      assert Matrix.object_at(matrix, {0, 0}) == nil
      assert Matrix.object_at(matrix, {0, 1}) == Objects.HealthPack.new()
      assert Matrix.object_at(matrix, {1, 0}) == Objects.AmmoPack.new()
      assert Matrix.object_at(matrix, {1, 1}) == Objects.Player.new("foo")
      assert Matrix.object_at(matrix, {0, 2}) == nil
    end
  end

  describe "object_at?/2" do
    test "returns true if the given coordinates have an object, or false if they don't" do
      matrix = [
        [:"#", Objects.AmmoPack.new()],
        [Objects.HealthPack.new(), Objects.Player.new("foo")],
        [:" ", :" "]
      ]

      assert Matrix.object_at?(matrix, {0, 0}) == false
      assert Matrix.object_at?(matrix, {0, 1}) == true
      assert Matrix.object_at?(matrix, {1, 0}) == true
      assert Matrix.object_at?(matrix, {1, 1}) == true
      assert Matrix.object_at?(matrix, {0, 2}) == false
    end
  end

  describe "player_at/2" do
    test "returns the player if the given coordinates have a player, or nil if it's not a player" do
      matrix = [
        [:"#", Objects.AmmoPack.new()],
        [Objects.HealthPack.new(), Objects.Player.new("foo")],
        [:" ", :" "]
      ]

      assert Matrix.player_at(matrix, {0, 0}) == nil
      assert Matrix.player_at(matrix, {0, 1}) == nil
      assert Matrix.player_at(matrix, {1, 0}) == nil
      assert Matrix.player_at(matrix, {1, 1}) == Objects.Player.new("foo")
      assert Matrix.player_at(matrix, {0, 2}) == nil
    end
  end

  describe "player_at?/2" do
    test "returns true if the given coordinates have a player, or false if it's not a player" do
      matrix = [
        [:"#", Objects.AmmoPack.new()],
        [Objects.HealthPack.new(), Objects.Player.new("foo")],
        [:" ", :" "]
      ]

      assert Matrix.player_at?(matrix, {0, 0}) == false
      assert Matrix.player_at?(matrix, {0, 1}) == false
      assert Matrix.player_at?(matrix, {1, 0}) == false
      assert Matrix.player_at?(matrix, {1, 1}) == true
      assert Matrix.player_at?(matrix, {0, 2}) == false
    end
  end

  describe "player_at/3" do
    test "returns the specific player if the given coordinates have that player, or nil" do
      matrix = [
        [:"#", Objects.AmmoPack.new()],
        [Objects.HealthPack.new(), Objects.Player.new("foo")],
        [:" ", :" "]
      ]

      assert Matrix.player_at(matrix, {0, 0}, "foo") == nil
      assert Matrix.player_at(matrix, {1, 1}, "foo") == Objects.Player.new("foo")
      assert Matrix.player_at(matrix, {1, 1}, "bar") == nil
    end
  end

  describe "player_at?/3" do
    test "returns true if the given coordinates have the player specified, or false" do
      matrix = [
        [:"#", Objects.AmmoPack.new()],
        [Objects.HealthPack.new(), Objects.Player.new("foo")],
        [:" ", :" "]
      ]

      assert Matrix.player_at?(matrix, {0, 0}, "foo") == false
      assert Matrix.player_at?(matrix, {1, 1}, "foo") == true
      assert Matrix.player_at?(matrix, {1, 1}, "bar") == false
    end
  end

  describe "at/2" do
    test "returns the value at the given coordinates" do
      matrix = [
        [:"#", Objects.AmmoPack.new()],
        [Objects.HealthPack.new(), Objects.Player.new("foo")],
        [:" ", :" "]
      ]

      assert Matrix.at(matrix, {0, 0}) == :"#"
      assert Matrix.at(matrix, {0, 1}) == Objects.HealthPack.new()
      assert Matrix.at(matrix, {1, 0}) == Objects.AmmoPack.new()
      assert Matrix.at(matrix, {1, 1}) == Objects.Player.new("foo")
      assert Matrix.at(matrix, {0, 2}) == :" "
    end
  end

  describe "clean/1" do
    test "clears everything that is not a wall or a space" do
      matrix = [
        [:"#", Objects.AmmoPack.new()],
        [Objects.HealthPack.new(), Objects.Player.new("foo")],
        [:"#", :"#"]
      ]

      assert Matrix.clean(matrix) == [[:"#", :" "], [:" ", :" "], [:"#", :"#"]]
    end
  end

  describe "map/2" do
    test "maps all positions of matrix" do
      matrix = [
        [:" ", :"#"],
        [:"#", :" "],
      ]

      fun = fn x -> if(x == :" ", do: :"#", else: :" ") end

      expected = [
        [:"#", :" "],
        [:" ", :"#"],
      ]

      assert Matrix.map(matrix, fun) == expected
    end
  end

  describe "iterate_towards/5" do
    setup [:set_up_iterate_towards_matrix]

    defp set_up_iterate_towards_matrix(_context) do
      matrix = [
        [:" ", :" ", :" ", :" ", :" ", :" ", :" "],
        [:" ", :" ", :" ", :" ", :" ", :" ", :" "],
        [:" ", :" ", :" ", :" ", :" ", :" ", :" "],
        [:" ", :" ", :" ", :" ", :" ", :" ", :" "],
        [:" ", :" ", :" ", :" ", :" ", :" ", :" "],
        [:" ", :" ", :" ", :" ", :" ", :" ", :" "],
        [:" ", :" ", :" ", :" ", :" ", :" ", :" "]
      ]

      list_reducer = fn coordinates, acc -> {:continue, acc ++ [coordinates]} end
      %{matrix: matrix, list_reducer: list_reducer}
    end

    test "iterates to the north until the end of the map if reducer function always returns {:continue, _}",
         context do
      result = Matrix.iterate_towards(context.matrix, {3, 3}, :north, [], context.list_reducer)
      assert result == [{3, 2}, {3, 1}, {3, 0}]
    end

    test "iterates to the south until the end of the map if reducer function always returns {:continue, _}",
         context do
      result = Matrix.iterate_towards(context.matrix, {3, 3}, :south, [], context.list_reducer)
      assert result == [{3, 4}, {3, 5}, {3, 6}]
    end

    test "iterates to the west until the end of the map if reducer function always returns {:continue, _}",
         context do
      result = Matrix.iterate_towards(context.matrix, {3, 3}, :west, [], context.list_reducer)
      assert result == [{2, 3}, {1, 3}, {0, 3}]
    end

    test "iterates to the east until the end of the map if reducer function always returns {:continue, _}",
         context do
      result = Matrix.iterate_towards(context.matrix, {3, 3}, :east, [], context.list_reducer)
      assert result == [{4, 3}, {5, 3}, {6, 3}]
    end

    test "stops when the reducer function returns {:stop, _}", context do
      reducer = fn coordinates, acc ->
        case coordinates do
          {3, 2} -> {:stop, acc ++ [coordinates]}
          _ -> {:continue, acc ++ [coordinates]}
        end
      end

      result = Matrix.iterate_towards(context.matrix, {3, 5}, :north, [], reducer)
      assert result == [{3, 4}, {3, 3}, {3, 2}]
    end
  end
end
