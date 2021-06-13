defmodule TextBasedFPS.CommandHelper do
  alias TextBasedFPS.ServerState
  alias TextBasedFPS.Room

  import TextBasedFPS.Text, only: [highlight: 1]

  @spec require_alive_player(ServerState.t, Player.t) :: {:ok, Room.t} | {:error, ServerState.t, String.t}
  def require_alive_player(state, player) do
    with {:ok, room} <- require_room(state, player) do
      room_player = Room.get_player(room, player.key)
      require_alive_player(state, player, room, room_player)
    end
  end
  defp require_alive_player(state, _player, _room, %{coordinates: nil}) do
    {:error, state, "You're dead. Type #{highlight("respawn")} to return to the game."}
  end
  defp require_alive_player(_state, _player, room, _room_player) do
    {:ok, room}
  end

  @spec require_room(ServerState.t, Player.t) :: {:ok, Room.t} | {:error, ServerState.t, String.t}
  def require_room(state, player) do
    if player.room do
      room = ServerState.get_room(state, player.room)
      {:ok, room}
    else
      {:error, state, room_required_message()}
    end
  end

  defp room_required_message() do
    "You need to be in a room to use this command. Type #{highlight("join-room <room_name>")} to join a room."
  end
end
