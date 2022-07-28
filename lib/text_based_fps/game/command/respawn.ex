defmodule TextBasedFPS.Game.Command.Respawn do
  import TextBasedFPS.Game.CommandHelper

  alias TextBasedFPS.GameState
  alias TextBasedFPS.Game.{Command, Room}

  @behaviour Command

  @impl true
  def execute(player, _) do
    with {:ok, _} <- require_room(player) do
      GameState.get_and_update_room(player.room, fn room ->
        case Room.respawn_player(room, player.key) do
          {:ok, updated_room} ->
            {{:ok, "You're back!"}, updated_room}

          {:error, :player_is_alive} ->
            {{:error, "You're already alive!"}, room}
        end
      end)
    end
  end
end
