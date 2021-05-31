defmodule TextBasedFPS.PlayerCommand.Health do
  alias TextBasedFPS.Room
  import TextBasedFPS.PlayerCommand.Util

  def execute(state, player, _) do
    require_room(state, player, fn room ->
      room_player = Room.get_player(room, player.key)
      {:ok, state, "Health: #{room_player.health}%"}
    end)
  end
end
