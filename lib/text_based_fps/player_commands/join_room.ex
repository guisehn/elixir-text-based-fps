defmodule TextBasedFPS.PlayerCommand.JoinRoom do
  alias TextBasedFPS.Room
  alias TextBasedFPS.ServerState
  import TextBasedFPS.PlayerCommand.Util

  def execute(state, player, room_name) do
    case player.name do
      nil -> {:error, state, name_required_message()}
      _ -> join_room(state, player, room_name)
    end
  end

  defp join_room(state, player, room_name) do
    updated_state = state
    |> remove_user_from_current_room(player)
    |> find_or_create_room(room_name)
    |> ServerState.update_room(room_name, fn room ->
      {:ok, room} = Room.add_player(room, player.key)
      room
    end)
    |> ServerState.update_player(player.key, fn player ->
      Map.put(player, :room, room_name)
    end)

    {:ok, updated_state, nil}
  end

  defp remove_user_from_current_room(state, player) do
    {_, updated_state} = ServerState.remove_player_from_current_room(state, player.key)
    updated_state
  end

  defp find_or_create_room(state, room_name) do
    room = state.rooms[room_name]
    find_or_create_room(state, room_name, room)
  end
  defp find_or_create_room(state, room_name, nil) do
    Map.put(state, :rooms, Map.put(state.rooms, room_name, Room.new(room_name)))
  end
  defp find_or_create_room(state, _room_name, _room), do: state

  defp name_required_message do
    "You need to have a name before joining a room. Type #{highlight("set-name <name>")} to set your name."
  end
end
