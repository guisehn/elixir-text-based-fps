defmodule TextBasedFPS.PlayerCommand.RoomList do
  import TextBasedFPS.PlayerCommand.Util

  def execute(state, _, _) do
    case map_size(state.rooms) do
      0 -> {:ok, state, empty_message()}
      _ -> {:ok, state, generate_table(state)}
    end
  end

  defp empty_message do
    "There are no rooms. Create your own room by typing #{highlight("join-room <room name>")}"
  end

  defp generate_table(state) do
    rows = Enum.map(state.rooms, fn {room_name, room} -> [room_name, map_size(room.players)] end)
    TableRex.quick_render!(rows, ~w(Name Players))
  end
end
