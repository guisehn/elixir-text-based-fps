defmodule TextBasedFPS.PlayerCommand.Health do
  import TextBasedFPS.CommandHelper

  alias TextBasedFPS.{PlayerCommand, Room}

  @behaviour PlayerCommand

  @impl true
  def execute(player, _) do
    with {:ok, room} <- require_room(player) do
      room_player = Room.get_player(room, player.key)
      {:ok, "Health: #{room_player.health}%"}
    end
  end
end
