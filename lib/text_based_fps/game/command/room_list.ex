defmodule TextBasedFPS.Game.Command.RoomList do
  alias TextBasedFPS.Game.Command
  alias TextBasedFPS.GameState
  alias TextBasedFPS.Text

  @behaviour Command

  @impl true
  def description, do: "View list of rooms"

  @impl true
  def execute(_, _) do
    case GameState.count_rooms() do
      0 -> {:ok, empty_message()}
      _ -> {:ok, generate_table()}
    end
  end

  defp empty_message do
    "There are no rooms. Create your own room by typing #{Text.highlight("join-room <room name>")}"
  end

  defp generate_table() do
    rows =
      GameState.get_rooms()
      |> Stream.map(fn room -> %{name: room.name, players: map_size(room.players)} end)
      |> Enum.sort_by(& &1.players)
      |> Stream.map(&[&1.name, &1.players])
      |> Enum.reverse()

    TableRex.quick_render!(rows, ~w(Name Players))
  end
end
