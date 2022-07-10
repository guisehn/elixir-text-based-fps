defmodule TextBasedFPS.PlayerCommand.LeaveRoom do
  import TextBasedFPS.CommandHelper

  alias TextBasedFPS.{Game, PlayerCommand, ServerState}

  @behaviour PlayerCommand

  @impl true
  def execute(player, _) do
    with {:ok, _room} <- require_room(player) do
      Game.remove_player_from_current_room(player)
      {:ok, "You have left the room."}
    end
  end
end
