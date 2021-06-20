defmodule TextBasedFPS.PlayerCommand.Respawn do
  import TextBasedFPS.CommandHelper

  alias TextBasedFPS.{PlayerCommand, Room, ServerState}

  @behaviour PlayerCommand

  @impl true
  def execute(state, player, _) do
    with {:ok, room} <- require_room(state, player) do
      case Room.respawn_player(room, player.key) do
        {:ok, updated_room} ->
          updated_state = ServerState.update_room(state, updated_room)
          {:ok, updated_state, "You're back!"}

        {:error, _room, reason} ->
          {:error, state, get_error_message(reason)}
      end
    end
  end

  defp get_error_message(:player_is_alive), do: "You're already alive!"
end
