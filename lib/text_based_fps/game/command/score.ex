defmodule TextBasedFPS.Game.Command.Score do
  import TextBasedFPS.Game.CommandHelper

  alias TextBasedFPS.GameState
  alias TextBasedFPS.Game.Command

  @behaviour Command

  @impl true
  def execute(player, _) do
    with {:ok, room} <- require_room(player) do
      {:ok, generate_table(room.players)}
    end
  end

  @table_header ~w(Name Score Deaths)
  defp generate_table(room_players) do
    rows =
      room_players
      |> Map.to_list()
      |> Stream.map(fn {_, player} -> player end)
      |> Enum.sort_by(& &1.kills)
      |> Enum.reverse()
      |> Enum.map(&generate_table_row/1)

    TableRex.quick_render!(rows, @table_header)
  end

  defp generate_table_row(room_player) do
    player = GameState.Players.get_player(room_player.player_key)
    [player.name, room_player.kills, room_player.killed]
  end
end
