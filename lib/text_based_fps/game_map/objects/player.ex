defmodule TextBasedFPS.GameMap.Objects.Player do
  alias TextBasedFPS.GameMap.Objects
  alias TextBasedFPS.Player

  @type t :: %TextBasedFPS.GameMap.Objects.Player{
          player_key: Player.key_t()
        }

  defstruct [:player_key]

  def new(player_key), do: %Objects.Player{player_key: player_key}

  defimpl TextBasedFPS.GameMap.Object do
    alias TextBasedFPS.Room
    alias TextBasedFPS.Direction

    def color(_), do: :danger

    def symbol(player_object, room) do
      room_player = Room.get_player(room, player_object.player_key)
      Direction.symbol_of(room_player.direction)
    end

    def grab(_, _), do: raise("Player cannot be grabbed")
  end
end
