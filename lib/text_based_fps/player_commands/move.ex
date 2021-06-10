defmodule TextBasedFPS.PlayerCommand.Move do
  alias TextBasedFPS.PlayerCommand
  alias TextBasedFPS.Direction
  alias TextBasedFPS.Room
  alias TextBasedFPS.ServerState

  import TextBasedFPS.PlayerCommand.Util
  import TextBasedFPS.Text, only: [highlight: 1]

  @behaviour PlayerCommand

  @impl true
  def execute(state, player, direction) do
    require_alive_player(state, player, fn room ->
      room_player = Room.get_player(room, player.key)
      parsed_direction = parse_direction(room_player, direction)
      move(state, room, room_player, parsed_direction)
    end)
  end

  defp parse_direction(room_player, ""), do: room_player.direction
  defp parse_direction(_room_player, direction), do: Direction.from_string(direction)

  defp move(state, _room, _room_player, nil) do
    {:error, state, "Unknown direction. Use #{highlight("<north/south/west/east>")}"}
  end

  defp move(state, room, room_player, direction) do
    {x, y} = Direction.calculate_movement(direction, room_player.coordinates)

    case Room.place_player_at(room, room_player.player_key, {x, y}) do
      {:ok, updated_room, object_grabbed} ->
        updated_state = ServerState.update_room(state, updated_room)
        {:ok, updated_state, grabbed_object_message(object_grabbed)}

      {:error, _} ->
        {:error, state, "You can't go in that direction."}
    end
  end

  defp grabbed_object_message(nil), do: nil
  defp grabbed_object_message(object), do: "You found: #{object}"
end
