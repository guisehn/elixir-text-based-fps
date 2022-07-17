defmodule TextBasedFPS.Game.Notifications do
  alias TextBasedFPS.{Game, GameState}

  @spec notify(Player.key_t(), String.t()) :: :ok
  def notify(player_key, msg), do: notifier_impl().notify(player_key, msg)

  def notify_room(room, msg, opts \\ [])

  def notify_room(room_name, msg, opts) when is_binary(room_name) do
    room_name
    |> GameState.Room.get()
    |> notify_room(msg, opts)
  end

  def notify_room(%Game.Room{} = room, msg, opts) do
    opts = Enum.into(opts, %{})
    player_keys = get_room_players(room, opts)
    Enum.each(player_keys, &notify(&1, msg))
  end

  defp get_room_players(_room, %{only: _, except: _}),
    do: raise("'only' and 'except' cannot be provided at the same time")

  defp get_room_players(_room, %{only: player_keys}) when is_list(player_keys), do: player_keys

  defp get_room_players(room, %{except: player_keys}) when is_list(player_keys),
    do: Map.keys(room.players) -- player_keys

  defp get_room_players(room, _), do: Map.keys(room.players)

  defp notifier_impl,
    do: Application.get_env(:text_based_fps, :notifier, TextBasedFPS.Game.Notifications.Notifier)
end
