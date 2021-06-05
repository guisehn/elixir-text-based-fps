defmodule TextBasedFPS.GameMap.Objects.AmmoPack do
  alias TextBasedFPS.GameMap.Objects.AmmoPack

  @default_amount 8

  @type t :: %TextBasedFPS.GameMap.Objects.AmmoPack{
    amount: non_neg_integer
  }

  defstruct [:amount]

  def new, do: %AmmoPack{amount: @default_amount}

  defimpl TextBasedFPS.GameMap.Object do
    def symbol(_, _), do: "¶"

    def grab(ammo_pack, room_player) do
      TextBasedFPS.RoomPlayer.add_ammo(room_player, ammo_pack.amount)
    end
  end

  defimpl String.Chars do
    def to_string(_), do: "Ammo pack"
  end
end
