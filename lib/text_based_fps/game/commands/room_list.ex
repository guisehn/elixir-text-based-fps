defmodule TextBasedFPS.PlayerCommand.RoomList do
  import TextBasedFPS.Text, only: [highlight: 1]

  alias TextBasedFPS.PlayerCommand
  alias TextBasedFPS.Process.RoomSupervisor

  @behaviour PlayerCommand

  @impl true
  def execute(_, _) do
    case RoomSupervisor.count_rooms() do
      0 -> {:ok, empty_message()}
      _ -> {:ok, generate_table()}
    end
  end

  defp empty_message do
    "There are no rooms. Create your own room by typing #{highlight("join-room <room name>")}"
  end

  defp generate_table() do
    rows =
      RoomSupervisor.get_rooms()
      |> Stream.map(fn room -> %{name: room.name, players: map_size(room.players)} end)
      |> Enum.sort_by(& &1.players)
      |> Stream.map(&[&1.name, &1.players])
      |> Enum.reverse()

    TableRex.quick_render!(rows, ~w(Name Players))
  end
end
