defmodule TextBasedFPS.PlayerCommand.Ammo do
  alias TextBasedFPS.Room
  alias TextBasedFPS.PlayerCommand
  import TextBasedFPS.RoomPlayer, only: [display_ammo: 1]
  import TextBasedFPS.PlayerCommand.Util

  @behaviour PlayerCommand

  @impl PlayerCommand
  def execute(state, player, _) do
    require_room(state, player, fn room ->
      room_player = Room.get_player(room, player.key)
      {:ok, state, "Ammo: #{display_ammo(room_player)}"}
    end)
  end
end
