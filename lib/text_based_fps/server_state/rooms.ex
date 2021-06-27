defmodule TextBasedFPS.ServerState.Rooms do
  alias TextBasedFPS.{Notification, Player, Room, ServerState, Text}

  @spec add_room(ServerState.t(), String.t()) :: ServerState.t()
  def add_room(state, room_name) do
    put_in(state.rooms[room_name], Room.new(room_name))
  end

  @spec add_room(ServerState.t(), String.t(), Player.key_t()) :: ServerState.t()
  def add_room(state, room_name, player_key) do
    state
    |> remove_player_from_current_room(player_key)
    |> add_room(room_name)
    |> join_room(room_name, player_key)
  end

  @spec get_room(ServerState.t(), String.t()) :: Room.t() | nil
  def get_room(state, room_name), do: state.rooms[room_name]

  @spec update_room(ServerState.t(), String.t(), function) :: ServerState.t()
  def update_room(state, room_name, fun) when is_function(fun) do
    room = state.rooms[room_name]
    updated_room = fun.(room)
    put_in(state.rooms[room_name], updated_room)
  end

  @spec join_room(ServerState.t(), String.t(), Player.key_t()) :: ServerState.t()
  def join_room(state, room_name, player_key) do
    state
    |> remove_player_from_current_room(player_key)
    |> update_room(room_name, fn room -> Room.add_player(room, player_key) end)
    |> ServerState.Players.update_player(player_key, fn player ->
      Map.put(player, :room, room_name)
    end)
  end

  @spec update_room(ServerState.t(), Room.t()) :: ServerState.t()
  def update_room(state, room) when is_map(room) do
    put_in(state.rooms[room.name], room)
  end

  @spec remove_player_from_current_room(ServerState.t(), Player.key_t()) :: ServerState.t()
  def remove_player_from_current_room(state, player_key) do
    player = state.players[player_key]

    if player do
      remove_player_from_room(state, player_key, player.room)
    else
      state
    end
  end

  @spec notify_room(ServerState.t(), String.t(), String.t()) :: ServerState.t()
  def notify_room(state, room_name, notification_body) do
    notify_room_except_player(state, room_name, nil, notification_body)
  end

  @spec notify_room_except_player(ServerState.t(), String.t(), Player.key_t() | nil, String.t()) ::
          ServerState.t()
  def notify_room_except_player(state, room_name, except_player_key, notification_body) do
    notifications =
      state.rooms[room_name].players
      |> Enum.filter(fn {player_key, _} -> player_key != except_player_key end)
      |> Enum.map(fn {player_key, _} -> Notification.new(player_key, notification_body) end)

    ServerState.Notifications.add_notifications(state, notifications)
  end

  defp remove_player_from_room(state, _player_key, nil), do: state

  defp remove_player_from_room(state, player_key, room_name) do
    updated_room = state |> get_room(room_name) |> Room.remove_player(player_key)

    state
    |> update_room(updated_room)
    |> notify_player_leaving_room(updated_room, player_key)
    |> remove_room_if_empty(updated_room)
    |> ServerState.Players.update_player(player_key, fn player -> Map.put(player, :room, nil) end)
  end

  defp remove_room_if_empty(state, room) do
    if Enum.count(room.players) == 0 do
      updated_rooms = Map.delete(state.rooms, room.name)
      Map.put(state, :rooms, updated_rooms)
    else
      state
    end
  end

  defp notify_player_leaving_room(state, room, leaving_player_key) do
    leaving_player = state.players[leaving_player_key]
    notify_room(state, room.name, Text.highlight("#{leaving_player.name} left the room"))
  end
end
