defmodule TextBasedFPS.PlayerCommand.Ammo do
  alias TextBasedFPS.Room
  import TextBasedFPS.RoomPlayer, only: [display_ammo: 1]
  import TextBasedFPS.PlayerCommand.Util

  def execute(state, player, _) do
    require_room(state, player, fn room ->
      room_player = Room.get_player(room, player.key)
      {:ok, state, "Ammo: #{display_ammo(room_player)}"}
    end)
  end
end
