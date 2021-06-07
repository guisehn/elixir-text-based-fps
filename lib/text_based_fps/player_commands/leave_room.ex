defmodule TextBasedFPS.PlayerCommand.LeaveRoom do
  alias TextBasedFPS.PlayerCommand
  alias TextBasedFPS.ServerState

  import TextBasedFPS.PlayerCommand.Util

  @behaviour PlayerCommand

  @impl true
  def execute(state, player, _) do
    require_room(state, player, fn _ ->
      updated_state = ServerState.remove_player_from_current_room(state, player.key)
      {:ok, updated_state, "You have left the room."}
    end)
  end
end
