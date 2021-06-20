defmodule TextBasedFPS.PlayerCommand.Health do
  import TextBasedFPS.CommandHelper

  alias TextBasedFPS.{PlayerCommand, Room}

  @behaviour PlayerCommand

  @impl true
  def execute(state, player, _) do
    with {:ok, room} <- require_room(state, player) do
      room_player = Room.get_player(room, player.key)
      {:ok, state, "Health: #{room_player.health}%"}
    end
  end
end
