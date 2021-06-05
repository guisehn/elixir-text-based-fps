defmodule TextBasedFPS.ServerState do
  alias TextBasedFPS.Notification
  alias TextBasedFPS.Player
  alias TextBasedFPS.Room
  alias TextBasedFPS.ServerState

  @type t :: %TextBasedFPS.ServerState{
    rooms: %{String.t => Room.t},
    players: %{String.t => Player.t},
    notifications: list(Notification.t)
  }

  defstruct [:rooms, :players, :notifications]

  def new do
    %ServerState{players: %{}, rooms: %{}, notifications: []}
  end

  def add_player(state, key \\ nil) do
    if Map.has_key?(state.players, key) do
      {key, state}
    else
      player = Player.new(key)
      updated_state = put_in(state.players[player.key], player)
      {player.key, updated_state}
    end
  end

  def add_notification(state, notification) do
    Map.put(state, :notifications, state.notifications ++ [notification])
  end
  def add_notifications(state, notification) do
    Map.put(state, :notifications, state.notifications ++ notification)
  end

  def get_and_clear_notifications(state) do
    updated_state = Map.put(state, :notifications, [])
    {state.notifications, updated_state}
  end
  def get_and_clear_notifications(state, player_key) do
    player_notifications = Enum.filter(state.notifications, &(&1.player_key == player_key))
    updated_state = Map.put(state, :notifications, state.notifications -- player_notifications)
    {player_notifications, updated_state}
  end

  def update_room(state, room_name, fun) when is_function(fun) do
    room = state.rooms[room_name]
    updated_room = fun.(room)
    put_in(state.rooms[room_name], updated_room)
  end
  def update_room(state, room) when is_map(room) do
    put_in(state.rooms[room.name], room)
  end

  def update_player(state, player_key, fun) do
    player = get_player(state, player_key)
    if player do
      updated_player = fun.(player)
      put_in(state.players[player_key], updated_player)
    else
      state
    end
  end

  def remove_player(state, player_key) do
    {_, state} = remove_player_from_current_room(state, player_key)
    Map.put(state, :players, Map.delete(state.players, player_key))
  end

  def remove_player_from_current_room(state, player_key) do
    player = get_player(state, player_key)
    if player do
      remove_player_from_room(state, player_key, player.room)
    else
      {:player_not_found, state}
    end
  end
  defp remove_player_from_room(state, _player_key, nil), do: {:not_in_room, state}
  defp remove_player_from_room(state, player_key, room_name) do
    updated_room = state |> get_room(room_name) |> Room.remove_player(player_key)
    updated_state = state
    |> update_room(updated_room)
    |> update_player(player_key, fn player -> Map.put(player, :room, nil) end)
    {:ok, updated_state}
  end

  def get_player(state, player_key), do: state.players[player_key]

  def get_room(state, room_name), do: state.rooms[room_name]
end
