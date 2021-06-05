defmodule TextBasedFPS.PlayerCommand.Reload do
  alias TextBasedFPS.PlayerCommand
  alias TextBasedFPS.Room

  import TextBasedFPS.RoomPlayer, only: [display_ammo: 1, reload_gun: 1]
  import TextBasedFPS.PlayerCommand.Util

  @behaviour PlayerCommand

  @impl true
  def execute(state, player, _) do
    require_alive_player(state, player, fn room ->
      room_player = Room.get_player(room, player.key)

      case reload_gun(room_player) do
        {:reloaded, updated_player} ->
          updated_state = put_in(state.rooms[room.name].players[player.key], updated_player)
          {:ok, updated_state, "You've reloaded. Ammo: #{display_ammo(updated_player)}"}

        {:no_ammo, _} -> {:error, state, "You're out of ammo"}
        {:full, _} -> {:error, state, "Your gun is full"}
      end
    end)
  end
end
