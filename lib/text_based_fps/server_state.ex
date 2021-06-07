defmodule TextBasedFPS.ServerState do
  alias TextBasedFPS.Notification
  alias TextBasedFPS.Player
  alias TextBasedFPS.Room
  alias TextBasedFPS.ServerState
  alias TextBasedFPS.Text

  @type t :: %TextBasedFPS.ServerState{
    rooms: %{String.t => Room.t},
    players: %{String.t => Player.t},
    notifications: list(Notification.t)
  }

  defstruct [:rooms, :players, :notifications]

  @spec new() :: ServerState.t
  def new do
    %ServerState{players: %{}, rooms: %{}, notifications: []}
  end

  @spec add_player(ServerState.t, Player.key_t | nil) :: {Player.key_t, ServerState.t}
  def add_player(state, key \\ nil) do
    if Map.has_key?(state.players, key) do
      {key, state}
    else
      player = Player.new(key)
      updated_state = put_in(state.players[player.key], player)
      {player.key, updated_state}
    end
  end

  @spec add_notifications(ServerState.t, list(Notification.t)) :: ServerState.t
  def add_notifications(state, notifications) do
    Map.put(state, :notifications, state.notifications ++ notifications)
  end

  @spec notify_room(ServerState.t, String.t, String.t) :: ServerState.t
  def notify_room(state, room_name, notification_body) do
    notify_room_except_player(state, room_name, nil, notification_body)
  end

  @spec notify_room_except_player(ServerState.t, String.t, Player.key_t | nil, String.t) :: ServerState.t
  def notify_room_except_player(state, room_name, except_player_key, notification_body) do
    notifications = state.rooms[room_name].players
    |> Enum.filter(fn {player_key, _} -> player_key != except_player_key end)
    |> Enum.map(fn {player_key, _} -> Notification.new(player_key, notification_body) end)
    add_notifications(state, notifications)
  end

  @spec get_and_clear_notifications(ServerState.t) :: {list(Notification.t), ServerState.t}
  def get_and_clear_notifications(state) do
    updated_state = Map.put(state, :notifications, [])
    {state.notifications, updated_state}
  end

  @spec get_and_clear_notifications(ServerState.t, Player.key_t) :: {list(Notification.t), ServerState.t}
  def get_and_clear_notifications(state, player_key) do
    player_notifications = Enum.filter(state.notifications, &(&1.player_key == player_key))
    updated_state = Map.put(state, :notifications, state.notifications -- player_notifications)
    {player_notifications, updated_state}
  end

  @spec update_room(ServerState.t, String.t, function) :: ServerState.t
  def update_room(state, room_name, fun) when is_function(fun) do
    room = state.rooms[room_name]
    updated_room = fun.(room)
    put_in(state.rooms[room_name], updated_room)
  end

  @spec add_room(ServerState.t, String.t) :: ServerState.t
  def add_room(state, room_name) do
    put_in(state.rooms[room_name], Room.new(room_name))
  end

  @spec add_room(ServerState.t, String.t, Player.key_t) :: ServerState.t
  def add_room(state, room_name, player_key) do
    state
    |> remove_player_from_current_room(player_key)
    |> add_room(room_name)
    |> join_room(room_name, player_key)
  end

  @spec join_room(ServerState.t, String.t, Player.key_t) :: ServerState.t
  def join_room(state, room_name, player_key) do
    state
    |> remove_player_from_current_room(player_key)
    |> update_room(room_name, fn room -> Room.add_player(room, player_key) end)
    |> update_player(player_key, fn player -> Map.put(player, :room, room_name) end)
  end

  @spec update_room(ServerState.t, Room.t) :: ServerState.t
  def update_room(state, room) when is_map(room) do
    put_in(state.rooms[room.name], room)
  end

  @spec update_player(ServerState.t, Player.key_t, function) :: ServerState.t
  def update_player(state, player_key, fun) do
    player = get_player(state, player_key)
    if player do
      updated_player = fun.(player)
      put_in(state.players[player_key], updated_player)
    else
      state
    end
  end

  @spec remove_player(ServerState.t, Player.key_t) :: ServerState.t
  def remove_player(state, player_key) do
    state
    |> remove_player_from_current_room(player_key)
    |> Map.put(:players, Map.delete(state.players, player_key))
  end

  @spec remove_player_from_current_room(ServerState.t, Player.key_t) :: ServerState.t
  def remove_player_from_current_room(state, player_key) do
    player = get_player(state, player_key)
    if player do
      remove_player_from_room(state, player_key, player.room)
    else
      state
    end
  end
  defp remove_player_from_room(state, _player_key, nil), do: state
  defp remove_player_from_room(state, player_key, room_name) do
    updated_room = state |> get_room(room_name) |> Room.remove_player(player_key)
    state
    |> update_room(updated_room)
    |> notify_user_leaving_room(updated_room, player_key)
    |> remove_room_if_empty(updated_room)
    |> update_player(player_key, fn player -> Map.put(player, :room, nil) end)
  end
  defp remove_room_if_empty(state, room) do
    if Enum.count(room.players) == 0 do
      updated_rooms = Map.delete(state.rooms, room.name)
      Map.put(state, :rooms, updated_rooms)
    else
      state
    end
  end
  defp notify_user_leaving_room(state, room, leaving_player_key) do
    leaving_player = get_player(state, leaving_player_key)
    notify_room(state, room.name, Text.highlight("#{leaving_player.name} left the room"))
  end

  @spec get_player(ServerState.t, Player.key_t) :: Player.t | nil
  def get_player(state, player_key), do: state.players[player_key]

  @spec get_room(ServerState.t, String.t) :: Room.t | nil
  def get_room(state, room_name), do: state.rooms[room_name]
end
