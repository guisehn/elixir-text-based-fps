defmodule TextBasedFPS.PlayerCommand.Score do
  import TextBasedFPS.CommandHelper

  alias TextBasedFPS.{PlayerCommand, ServerState}

  @table_header ~w(Name Score Deaths)

  @behaviour PlayerCommand

  @impl true
  def execute(state, player, _) do
    with {:ok, room} <- require_room(state, player) do
      {:ok, state, generate_table(state, room.players)}
    end
  end

  defp generate_table(state, players) do
    rows =
      players
      |> Map.to_list()
      |> Stream.map(fn {_, player} -> player end)
      |> Enum.sort_by(& &1.kills)
      |> Enum.reverse()
      |> Enum.map(&generate_table_row(state, &1))

    TableRex.quick_render!(rows, @table_header)
  end

  defp generate_table_row(state, room_player) do
    player = ServerState.get_player(state, room_player.player_key)
    [player.name, room_player.kills, room_player.killed]
  end
end
