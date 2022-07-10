defmodule TextBasedFPS.PlayerCommand.LeaveRoom do
  import TextBasedFPS.CommandHelper

  alias TextBasedFPS.{Game, PlayerCommand}

  @behaviour PlayerCommand

  @impl true
  def execute(player, _) do
    with {:ok, _room} <- require_room(player) do
      Game.leave_room(player.key)
      {:ok, "You have left the room."}
    end
  end
end
