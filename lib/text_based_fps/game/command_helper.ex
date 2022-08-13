defmodule TextBasedFPS.Game.CommandHelper do
  import TextBasedFPS.Text, only: [highlight: 1]

  alias TextBasedFPS.{Game, GameState}

  @doc """
  Returns an ok tuple with the room if the user is in a room, and alive.
  If it's not the case, returns an error tuple.

  This function is useful in a `with` statement inside a command. For instance:

      with {:ok, room} <- require_alive_player(player) do
        # do something with `player` and `room`
      end
  """
  @spec require_alive_player(Game.Player.t()) :: {:ok, Game.Room.t()} | {:error, String.t()}
  def require_alive_player(player) do
    with {:ok, room} <- require_room(player) do
      room_player = Game.Room.get_player(room, player.key)
      require_alive_player(player, room, room_player)
    end
  end

  defp require_alive_player(_player, _room, %{coordinates: nil}) do
    {:error, "You're dead. Type #{highlight("respawn")} to return to the game."}
  end

  defp require_alive_player(_player, room, _room_player) do
    {:ok, room}
  end

  @doc """
  Returns an ok tuple with the room if the user is in a room.
  If it's not the case, returns an error tuple.

  This function is useful in a `with` statement inside a command. For instance:

      with {:ok, room} <- require_room(player) do
        # do something with `player` and `room`
      end
  """
  @spec require_room(Game.Player.t()) :: {:ok, Game.Room.t()} | {:error, String.t()}
  def require_room(player) do
    if player.room do
      {:ok, GameState.get_room(player.room)}
    else
      {:error, room_required_message()}
    end
  end

  defp room_required_message do
    "You need to be in a room to use this command. Type #{highlight("join-room <room_name>")} to join a room."
  end
end
