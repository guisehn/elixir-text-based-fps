defmodule TextBasedFPS.Game.Command.Move do
  import TextBasedFPS.Game.CommandHelper

  alias TextBasedFPS.{Process, Text}
  alias TextBasedFPS.Game.{Command, Direction, Room}

  @behaviour Command

  @impl true
  def execute(player, direction) do
    with {:ok, _} <- require_alive_player(player) do
      Process.Room.get_and_update(player.room, fn room ->
        room_player = Room.get_player(room, player.key)
        parsed_direction = parse_direction(room_player, direction)
        move(room, room_player, parsed_direction)
      end)
    end
  end

  defp parse_direction(room_player, ""), do: room_player.direction
  defp parse_direction(_room_player, direction), do: Direction.from_string(direction)

  defp move(room, _room_player, nil = _parsed_direction) do
    msg = {:error, "Unknown direction. Use #{Text.highlight("<north/south/west/east>")}"}
    {msg, room}
  end

  defp move(room, room_player, direction) do
    {x, y} = Direction.calculate_movement(direction, room_player.coordinates)

    case Room.place_player_at(room, room_player.player_key, {x, y}) do
      {:ok, updated_room, object_grabbed} ->
        {{:ok, grabbed_object_message(object_grabbed)}, updated_room}

      {:error, _} ->
        {{:error, "You can't go in that direction."}, room}
    end
  end

  defp grabbed_object_message(nil), do: nil
  defp grabbed_object_message(object), do: "You found: #{object}"
end
