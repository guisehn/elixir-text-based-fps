defmodule TextBasedFPS.PlayerCommand.Look do
  import TextBasedFPS.CommandHelper

  alias TextBasedFPS.{
    GameMap,
    PlayerCommand,
    Room,
    Text
  }

  alias TextBasedFPS.GameMap.Objects

  @behaviour PlayerCommand

  @impl true
  def execute(player, _) do
    with {:ok, room} <- require_alive_player(player) do
      {:ok, generate_vision(player, room)}
    end
  end

  defp generate_vision(player, room) do
    room_player = Room.get_player(room, player.key)

    vision_matrix =
      GameMap.Matrix.map(room.game_map.matrix, fn item ->
        if Objects.object?(item) do
          display_object(item, room)
        else
          item
        end
      end)

    GameMap.Matrix.set(vision_matrix, room_player.coordinates, display_me(room_player, room))
    |> Stream.map(fn line -> Enum.join(line, " ") end)
    |> Enum.join("\n")
  end

  defp display_object(object, room) do
    color = GameMap.Object.color(object)
    symbol = GameMap.Object.symbol(object, room)
    Text.paint(symbol, color)
  end

  defp display_me(me, room) do
    player_object = GameMap.Objects.Player.new(me.player_key)
    Text.success(GameMap.Object.symbol(player_object, room))
  end
end
