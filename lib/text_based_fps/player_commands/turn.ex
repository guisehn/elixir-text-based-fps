defmodule TextBasedFPS.PlayerCommand.Turn do
  alias TextBasedFPS.PlayerCommand
  alias TextBasedFPS.Direction
  alias TextBasedFPS.Room

  import TextBasedFPS.PlayerCommand.Util
  import TextBasedFPS.Text

  @behaviour PlayerCommand

  @impl true
  def execute(state, player, direction) do
    require_alive_player(state, player, fn room ->
      room_player = Room.get_player(room, player.key)
      parsed_direction = parse_direction(room_player, direction)
      turn(state, player.room, player, parsed_direction)
    end)
  end

  defp parse_direction(room_player, "around"), do: Direction.inverse_of(room_player.direction)
  defp parse_direction(_room_player, direction), do: Direction.from_string(direction)

  defp turn(state, _room_name, _player, nil) do
    {:error, state, unknown_direction_message()}
  end

  defp turn(state, room_name, player, direction) do
    updated_state = put_in(state.rooms[room_name].players[player.key].direction, direction)
    {:ok, updated_state, nil}
  end

  defp unknown_direction_message do
    "Unknown direction. Use #{highlight("<north/south/west/east/around>")}"
  end
end
