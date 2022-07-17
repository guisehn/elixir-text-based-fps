defmodule TextBasedFPS.Game.Command.LeaveRoom do
  import TextBasedFPS.Game.CommandHelper

  alias TextBasedFPS.Game.Command
  alias TextBasedFPS.GameState

  @behaviour Command

  @impl true
  def execute(player, _) do
    with {:ok, _room} <- require_room(player) do
      GameState.leave_room(player.key)
      {:ok, "You have left the room."}
    end
  end
end
