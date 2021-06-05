defmodule TextBasedFPS.PlayerCommand.Score do
  alias TextBasedFPS.PlayerCommand
  alias TextBasedFPS.ServerState

  import TextBasedFPS.PlayerCommand.Util

  @table_header ~w(Name Score Deaths)

  @behaviour PlayerCommand

  @impl true
  def execute(state, player, _) do
    require_room(state, player, fn room ->
      {:ok, state, generate_table(state, room.players)}
    end)
  end

  defp generate_table(state, players) do
    rows = players
    |> Map.to_list
    |> Enum.map(fn {_, player} -> generate_table_row(state, player) end)

    TableRex.quick_render!(rows, @table_header)
  end

  defp generate_table_row(state, room_player) do
    player = ServerState.get_player(state, room_player.player_key)
    [player.name, room_player.kills, room_player.killed]
  end
end
