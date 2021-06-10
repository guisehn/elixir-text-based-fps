defmodule TextBasedFPS.PlayerCommand.Util do
  alias TextBasedFPS.ServerState
  alias TextBasedFPS.Room

  import TextBasedFPS.Text, only: [highlight: 1]

  def require_alive_player(state, player, fun) do
    require_room(state, player, fn room ->
      case Room.get_player(room, player.key) do
        %{coordinates: nil} ->
          {:error, state, "You're dead. Type #{highlight("respawn")} to return to the game."}

        _ -> fun.(room)
      end
    end)
  end

  def require_room(state, player, fun) do
    require_room_with_name(state, player.room, fun)
  end
  defp require_room_with_name(state, nil, _fun) do
    message = "You need to be in a room to use this command. "
      <> "Type #{highlight("join-room <room_name>")} to join a room."

    {:error, state, message}
  end

  defp require_room_with_name(state, room_name, fun) do
    room = ServerState.get_room(state, room_name)
    fun.(room)
  end
end
