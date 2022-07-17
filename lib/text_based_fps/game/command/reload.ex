defmodule TextBasedFPS.Game.Command.Reload do
  import TextBasedFPS.Game.CommandHelper

  alias TextBasedFPS.GameState
  alias TextBasedFPS.Game.{Command, Room, RoomPlayer}

  @behaviour Command

  @impl true
  def execute(player, _) do
    with {:ok, _} <- require_alive_player(player) do
      GameState.Room.get_and_update(player.room, fn room ->
        room_player = Room.get_player(room, player.key)

        case RoomPlayer.reload_gun(room_player) do
          {:reloaded, updated_player} ->
            updated_room = put_in(room.players[player.key], updated_player)
            msg = {:ok, "You've reloaded. Ammo: #{RoomPlayer.display_ammo(updated_player)}"}
            {msg, updated_room}

          {:no_ammo, _} ->
            {{:error, "You're out of ammo"}, room}

          {:full, _} ->
            {{:error, "Your gun is full"}, room}
        end
      end)
    end
  end
end
