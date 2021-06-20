defmodule TextBasedFPS.PlayerCommand.RoomList do
  import TextBasedFPS.Text, only: [highlight: 1]

  alias TextBasedFPS.PlayerCommand

  @behaviour PlayerCommand

  @impl true
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
    rows =
      state.rooms
      |> Map.to_list()
      |> Stream.map(fn {_, room} -> room end)
      |> Stream.map(fn room -> %{name: room.name, players: map_size(room.players)} end)
      |> Enum.sort_by(& &1.players)
      |> Stream.map(&[&1.name, &1.players])
      |> Enum.reverse()

    TableRex.quick_render!(rows, ~w(Name Players))
  end
end
