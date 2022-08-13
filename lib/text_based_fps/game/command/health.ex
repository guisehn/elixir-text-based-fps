defmodule TextBasedFPS.Game.Command.Health do
  import TextBasedFPS.Game.CommandHelper

  alias TextBasedFPS.Game.{Command, Room}

  @behaviour Command

  @impl true
  def description, do: "Show your current health level"

  @impl true
  def execute(player, _) do
    with {:ok, room} <- require_room(player) do
      room_player = Room.get_player(room, player.key)
      {:ok, "Health: #{room_player.health}%"}
    end
  end
end
