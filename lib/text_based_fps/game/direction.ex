defmodule TextBasedFPS.Direction do
  @type t :: :north | :south | :west | :east

  defguard is_direction(direction) when direction in [:north, :south, :west, :east]

  @spec all :: [t]
  def all, do: [:north, :south, :west, :east]

  @spec from_string(binary) :: t | nil
  def from_string("north"), do: :north
  def from_string("south"), do: :south
  def from_string("west"), do: :west
  def from_string("east"), do: :east
  def from_string(_), do: nil

  @spec inverse_of(t) :: t
  def inverse_of(:north), do: :south
  def inverse_of(:south), do: :north
  def inverse_of(:west), do: :east
  def inverse_of(:east), do: :west

  @spec symbol_of(t) :: String.t()
  def symbol_of(:north), do: "▲"
  def symbol_of(:south), do: "▼"
  def symbol_of(:west), do: "◄"
  def symbol_of(:east), do: "►"

  @spec calculate_movement(t, {integer, integer}) :: {integer, integer}
  def calculate_movement(:north, {x, y}), do: {x, y - 1}
  def calculate_movement(:south, {x, y}), do: {x, y + 1}
  def calculate_movement(:west, {x, y}), do: {x - 1, y}
  def calculate_movement(:east, {x, y}), do: {x + 1, y}

  @spec from_respawn_position_char(atom) :: t
  def from_respawn_position_char(:N), do: :north
  def from_respawn_position_char(:S), do: :south
  def from_respawn_position_char(:W), do: :west
  def from_respawn_position_char(:E), do: :east
end
