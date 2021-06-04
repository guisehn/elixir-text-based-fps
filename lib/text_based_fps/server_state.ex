defmodule TextBasedFPS.ServerState do
  alias TextBasedFPS.ServerState
  alias TextBasedFPS.Player
  alias TextBasedFPS.Room

  defstruct [:rooms, :players]

  def new do
    %ServerState{players: %{}, rooms: %{}}
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

  def update_room(state, room_name, fun) when is_function(fun) do
    room = state.rooms[room_name]
    updated_room = fun.(room)
    updated_rooms = Map.put(state.rooms, room_name, updated_room)
    Map.put(state, :rooms, updated_rooms)
  end
  def update_room(state, room) when is_map(room) do
    updated_rooms = Map.put(state.rooms, room.name, room)
    Map.put(state, :rooms, updated_rooms)
  end

  def update_player(state, player_key, fun) do
    player = get_player(state, player_key)
    updated_player = fun.(player)
    updated_players = Map.put(state.players, player_key, updated_player)
    Map.put(state, :players, updated_players)
  end

  def remove_player(state, player_key) do
    {_, state} = remove_player_from_current_room(state, player_key)
    Map.put(state, :players, Map.delete(state.players, player_key))
  end

  def remove_player_from_current_room(state, player_key) do
    player = get_player(state, player_key)
    remove_player_from_room(state, player_key, player.room)
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
