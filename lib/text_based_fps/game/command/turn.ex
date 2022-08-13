defmodule TextBasedFPS.Game.Command.Turn do
  import TextBasedFPS.Game.CommandHelper

  alias TextBasedFPS.Game.{Command, Direction, GameState, Room}
  alias TextBasedFPS.{GameState, Text}

  @behaviour Command

  @impl true
  def arg_example, do: "north/south/west/east/around"

  @impl true
  def description, do: "Turn to another direction so that you can shoot other players"

  @impl true
  def execute(player, direction) do
    with {:ok, room} <- require_alive_player(player) do
      room_player = Room.get_player(room, player.key)
      parsed_direction = parse_direction(room_player, direction)
      turn(player.room, player, parsed_direction)
    end
  end

  defp parse_direction(room_player, "around"), do: Direction.inverse_of(room_player.direction)
  defp parse_direction(_room_player, direction), do: Direction.from_string(direction)

  defp turn(_room_name, _player, nil) do
    {:error, "Unknown direction. Use #{Text.highlight("<north/south/west/east/around>")}"}
  end

  defp turn(room_name, player, direction) do
    GameState.update_room(room_name, fn room ->
      put_in(room.players[player.key].direction, direction)
    end)

    {:ok, nil}
  end
end
