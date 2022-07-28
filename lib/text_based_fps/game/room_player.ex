defmodule TextBasedFPS.Game.RoomPlayer do
  @moduledoc "Represents a player, playing in a room"

  alias __MODULE__
  alias TextBasedFPS.Game.{Direction, Player}

  @max_health 100
  @max_loaded_ammo 8
  @max_unloaded_ammo 24

  @type t :: %RoomPlayer{
          player_key: Player.key_t(),
          coordinates: TextBasedFPS.GameMap.Coordinates.t() | nil,
          direction: Direction.t() | nil,
          health: non_neg_integer,
          ammo: {non_neg_integer, non_neg_integer},
          kills: non_neg_integer,
          killed: non_neg_integer
        }

  defstruct [:player_key, :coordinates, :direction, :health, :ammo, :kills, :killed]

  @spec new(Player.key_t()) :: t
  def new(player_key) do
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

  @spec dead?(t) :: boolean
  def dead?(room_player), do: room_player.health == 0

  @spec increment(t, atom) :: t
  def increment(room_player, key) do
    Map.put(room_player, key, Map.get(room_player, key) + 1)
  end

  @spec decrement(t, atom) :: t
  def decrement(room_player, :ammo) do
    {loaded, unloaded} = room_player.ammo
    Map.put(room_player, :ammo, {max(loaded - 1, 0), unloaded})
  end

  def decrement(room_player, key) do
    Map.put(room_player, key, Map.get(room_player, key) - 1)
  end

  @spec add_ammo(t, non_neg_integer) :: t
  def add_ammo(room_player, amount) do
    {loaded, unloaded} = room_player.ammo
    new_unloaded = min(unloaded + amount, @max_unloaded_ammo)
    Map.put(room_player, :ammo, {loaded, new_unloaded})
  end

  @spec heal(t, non_neg_integer) :: t
  def heal(room_player, amount) do
    new_health = min(room_player.health + amount, @max_health)
    Map.put(room_player, :health, new_health)
  end

  @spec reload_gun(t) :: {:reloaded, t} | {:full, t} | {:no_ammo, t}
  def reload_gun(room_player = %{ammo: {_, 0}}), do: {:no_ammo, room_player}

  def reload_gun(room_player) do
    {loaded, unloaded} = room_player.ammo
    amount_to_load = min(@max_loaded_ammo - loaded, unloaded)

    case amount_to_load do
      0 ->
        {:full, room_player}

      _ ->
        {:reloaded,
         Map.put(room_player, :ammo, {loaded + amount_to_load, unloaded - amount_to_load})}
    end
  end

  @spec display_ammo(t) :: String.t()
  def display_ammo(%{ammo: {loaded, unloaded}}) do
    "#{loaded}/#{unloaded}"
  end

  @spec max_health() :: non_neg_integer
  def max_health, do: @max_health

  @spec max_loaded_ammo() :: non_neg_integer
  def max_loaded_ammo, do: @max_loaded_ammo

  @spec max_unloaded_ammo() :: non_neg_integer
  def max_unloaded_ammo, do: @max_unloaded_ammo
end
