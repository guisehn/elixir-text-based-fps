defmodule TextBasedFPS.PlayerCommand.LeaveRoom do
  import TextBasedFPS.CommandHelper

  alias TextBasedFPS.{PlayerCommand, ServerState}

  @behaviour PlayerCommand

  @impl true
  def execute(state, player, _) do
    with {:ok, _room} <- require_room(state, player) do
      updated_state = ServerState.remove_player_from_current_room(state, player.key)
      {:ok, updated_state, "You have left the room."}
    end
  end
end
