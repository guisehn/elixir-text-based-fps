defmodule TextBasedFPS.DirectionTest do
  use ExUnit.Case, async: true

  alias TextBasedFPS.Direction

  require TextBasedFPS.Direction

  test "is_direction/1" do
    assert Direction.is_direction(:north) == true
    assert Direction.is_direction(:south) == true
    assert Direction.is_direction(:west) == true
    assert Direction.is_direction(:east) == true
    assert Direction.is_direction(:foo) == false
  end

  describe "calculate_movement/2" do
    test "decrements the Y coordinate when :north is specified" do
      assert Direction.calculate_movement(:north, {5, 2}) == {5, 1}
    end

    test "increments the Y coordinate when :south is specified" do
      assert Direction.calculate_movement(:south, {5, 2}) == {5, 3}
    end

    test "decrements the X coordinate when :west is specified" do
      assert Direction.calculate_movement(:west, {5, 2}) == {4, 2}
    end

    test "increments the X coordinate when :east is specified" do
      assert Direction.calculate_movement(:east, {5, 2}) == {6, 2}
    end
  end
end
