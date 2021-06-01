defmodule TextBasedFPS.PlayerCommand.Health do
  alias TextBasedFPS.PlayerCommand
  alias TextBasedFPS.Room
  import TextBasedFPS.PlayerCommand.Util

  @behaviour PlayerCommand

  @impl PlayerCommand
  def execute(state, player, _) do
    require_room(state, player, fn room ->
      room_player = Room.get_player(room, player.key)
      {:ok, state, "Health: #{room_player.health}%"}
    end)
  end
end
