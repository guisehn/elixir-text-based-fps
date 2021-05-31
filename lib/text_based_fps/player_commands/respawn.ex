defmodule TextBasedFPS.PlayerCommand.Respawn do
  alias TextBasedFPS.Room
  alias TextBasedFPS.ServerState
  import TextBasedFPS.PlayerCommand.Util

  def execute(state, player, _) do
    require_room(state, player, fn room ->
      case Room.respawn_player(room, player.key) do
        {:ok, updated_room} ->
          updated_state = ServerState.update_room(state, player.room, updated_room)
          {:ok, updated_state, "You're back!"}

        {:error, _room, reason} ->
          {:error, state, get_error_message(reason)}
      end
    end)
  end

  defp get_error_message(:player_is_alive), do: "You're already alive!"
end
