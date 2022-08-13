defmodule TextBasedFPS.Game.Command.Ammo do
  import TextBasedFPS.Game.CommandHelper

  alias TextBasedFPS.Game.{Command, Room, RoomPlayer}

  @behaviour Command

  @impl true
  def description, do: "Show how much ammo you have"

  @impl true
  def execute(player, _) do
    with {:ok, room} <- require_room(player) do
      room_player = Room.get_player(room, player.key)
      {:ok, "Ammo: #{RoomPlayer.display_ammo(room_player)}"}
    end
  end
end
