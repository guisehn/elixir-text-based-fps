defmodule TextBasedFPS.GameMap.Objects.HealthPack do
  alias TextBasedFPS.GameMap.Objects.HealthPack

  @default_amount 8

  @type t :: %TextBasedFPS.GameMap.Objects.HealthPack{
          amount: non_neg_integer
        }

  defstruct [:amount]

  def new, do: %HealthPack{amount: @default_amount}

  defimpl TextBasedFPS.GameMap.Object do
    def symbol(_, _), do: "+"

    def color(_), do: :info

    def grab(health_pack, room_player) do
      TextBasedFPS.Game.RoomPlayer.heal(room_player, health_pack.amount)
    end
  end

  defimpl String.Chars do
    def to_string(_), do: "Health pack"
  end
end
