defmodule TextBasedFPS.GameMap.Matrix do
  alias TextBasedFPS.GameMap
  alias TextBasedFPS.GameMap.Coordinates
  alias TextBasedFPS.GameMap.Objects
  alias TextBasedFPS.Direction

  @type t :: list(list())
  @type item_t :: :" " | :"#" | GameMap.Object.t

  @spec set(t, Coordinates.t, item_t) :: t
  def set(matrix, {x, y}, value) do
    updated_row = Enum.at(matrix, y) |> List.replace_at(x, value)
    List.replace_at(matrix, y, updated_row)
  end

  @spec clear(t, Coordinates.t) :: t
  def clear(matrix, {x, y}) do
    set(matrix, {x, y}, :" ")
  end

  @spec has?(t, Coordinates.t) :: boolean
  def has?(matrix, {x, y}) do
    at(matrix, {x, y}) != nil
  end

  @spec wall_at?(t, Coordinates.t) :: boolean
  def wall_at?(matrix, {x, y}) do
    at(matrix, {x, y}) == :"#"
  end

  @spec object_at(t, Coordinates.t) :: GameMap.Object.t | nil
  def object_at(matrix, {x, y}) do
    object = at(matrix, {x, y})
    if object?(object), do: object, else: nil
  end

  @spec object_at?(t, Coordinates.t) :: boolean
  def object_at?(matrix, {x, y}) do
    object_at(matrix, {x, y}) != nil
  end

  @spec player_at(t, Coordinates.t) :: Objects.Player.t | nil
  def player_at(matrix, {x, y}) do
    player = at(matrix, {x, y})
    if player?(player), do: player, else: nil
  end

  @spec player_at(t, Coordinates.t, Player.key_t) :: Objects.Player.t | nil
  def player_at(matrix, {x, y}, player_key) do
    player = player_at(matrix, {x, y})
    if player && player.player_key == player_key, do: player, else: nil
  end

  @spec player_at?(t, Coordinates.t) :: boolean
  def player_at?(matrix, {x, y}) do
    player_at(matrix, {x, y}) != nil
  end

  @spec player_at?(t, Coordinates.t, Player.key_t) :: boolean
  def player_at?(matrix, {x, y}, player_key) do
    player_at(matrix, {x, y}, player_key) != nil
  end

  @spec at(t, Coordinates.t) :: item_t | nil
  def at(matrix, {x, y}) do
    row = Enum.at(matrix, y)
    get_col(row, x)
  end
  defp get_col(nil, _x), do: nil
  defp get_col(row, x), do: Enum.at(row, x)

  @spec clean(t) :: t
  def clean(matrix) do
    Enum.map(matrix, fn line -> Enum.map(line, &clean_position/1) end)
  end
  defp clean_position(:"#"), do: :"#"
  defp clean_position(_), do: :" "

  @doc """
  Iterate on the map matrix from a coordinate towards a given direction until the end of the map.
  For each iteration, it'll call `fun`, which should return {:continue, acc} if it should proceed,
  or {:stop, acc}
  The final accumulated value will be returned.
  """
  @spec iterate_towards(t, Coordinates.t, Direction.t, any, function) :: any
  def iterate_towards(matrix, {x, y}, direction, acc, fun) do
    result = handle_iteration_fun_call(matrix, {x, y}, direction, acc, fun)
    case result do
      {:continue, updated_acc, next_coordinate} ->
        iterate_towards(matrix, next_coordinate, direction, updated_acc, fun)
      {:stop, updated_acc, _} -> updated_acc
    end
  end
  defp handle_iteration_fun_call(matrix, {x, y}, direction, acc, fun) do
    next_coordinate = Direction.calculate_movement(direction, {x, y})
    if has?(matrix, next_coordinate) do
      {action, updated_acc} = fun.(next_coordinate, acc)
      {action, updated_acc, next_coordinate}
    else
      {:stop, acc, next_coordinate}
    end
  end

  defp object?(object) do
    is_map(object) && object.__struct__
    |> Module.split()
    |> List.pop_at(-1)
    |> elem(1)
    |> Module.concat
    |> Kernel.==(TextBasedFPS.GameMap.Objects)
  end

  defp player?(object) do
    is_map(object) && object.__struct__ == TextBasedFPS.GameMap.Objects.Player
  end
end
