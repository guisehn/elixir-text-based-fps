defmodule TextBasedFPS.PlayerCommand.Ammo do
  alias TextBasedFPS.Room
  alias TextBasedFPS.PlayerCommand

  import TextBasedFPS.RoomPlayer, only: [display_ammo: 1]
  import TextBasedFPS.CommandHelper

  @behaviour PlayerCommand

  @impl true
  def execute(state, player, _) do
    with {:ok, room} <- require_room(state, player) do
      room_player = Room.get_player(room, player.key)
      {:ok, state, "Ammo: #{display_ammo(room_player)}"}
    end
  end
end
