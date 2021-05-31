defmodule TextBasedFPS.GameMap.Objects.HealthPack do
  alias TextBasedFPS.GameMap.Objects.HealthPack

  @default_amount 8

  defstruct [:amount]

  def new, do: %HealthPack{amount: @default_amount}

  defimpl TextBasedFPS.GameMap.Object do
    def symbol(_, _), do: "+"

    def grab(health_pack, room_player) do
      TextBasedFPS.RoomPlayer.heal(room_player, health_pack.amount)
    end
  end

  defimpl String.Chars do
    def to_string(_), do: "Health pack"
  end
end
