defmodule TextBasedFPS.RoomPlayer do
  alias TextBasedFPS.Direction
  alias TextBasedFPS.RoomPlayer

  @max_health 100
  @max_loaded_ammo 8
  @max_unloaded_ammo 24

  @type t :: %TextBasedFPS.RoomPlayer{
    player_key: String.t,
    coordinates: TextBasedFPS.GameMap.Coordinates.t,
    direction: Direction.t,
    health: non_neg_integer,
    ammo: {non_neg_integer, non_neg_integer},
    kills: non_neg_integer,
    killed: non_neg_integer
  }

  defstruct [:player_key, :coordinates, :direction, :health, :ammo, :kills, :killed]

  def build(player_key) do
    %RoomPlayer{
      player_key: player_key,
      coordinates: nil,
      direction: nil,
      health: 0,
      ammo: {0, 0},
      kills: 0,
      killed: 0
    }
  end

  def dead?(room_player), do: room_player.health == 0

  def increase(room_player, key) do
    Map.put(room_player, key, Map.get(room_player, key) + 1)
  end

  def decrease(room_player, :ammo) do
    {loaded, unloaded} = room_player.ammo
    Map.put(room_player, :ammo, {max(loaded - 1, 0), unloaded})
  end
  def decrease(room_player, key) do
    Map.put(room_player, key, Map.get(room_player, key) - 1)
  end

  def add_ammo(room_player, amount) do
    {loaded, unloaded} = room_player.ammo
    new_unloaded = min(unloaded + amount, @max_unloaded_ammo)
    Map.put(room_player, :ammo, {loaded, new_unloaded})
  end

  def heal(room_player, amount) do
    new_health = max(room_player.health + amount, @max_health)
    Map.put(room_player, :health, new_health)
  end

  def reload_gun(room_player = %{ammo: {_, 0}}), do: {:no_ammo, room_player}
  def reload_gun(room_player) do
    {loaded, unloaded} = room_player.ammo
    amount_to_load = min(@max_loaded_ammo - loaded, unloaded)
    case amount_to_load do
      0 -> {:full, room_player}
      _ -> {:reloaded, Map.put(room_player, :ammo, {loaded + amount_to_load, unloaded - amount_to_load})}
    end
  end

  def display_ammo(%{ammo: {loaded, unloaded}}) do
    "#{loaded}/#{unloaded}"
  end

  def max_health, do: @max_health
  def max_loaded_ammo, do: @max_loaded_ammo
  def max_unloaded_ammo, do: @max_unloaded_ammo
end
