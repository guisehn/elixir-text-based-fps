defmodule TextBasedFPS.PlayerCommand.Respawn do
  import TextBasedFPS.CommandHelper

  alias TextBasedFPS.{PlayerCommand, Process, Room}

  @behaviour PlayerCommand

  @impl true
  def execute(player, _) do
    with {:ok, _} <- require_room(player) do
      Process.Room.get_and_update(player.room, fn room ->
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
