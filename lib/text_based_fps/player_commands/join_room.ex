defmodule TextBasedFPS.PlayerCommand.JoinRoom do
  alias TextBasedFPS.PlayerCommand
  alias TextBasedFPS.Room
  alias TextBasedFPS.ServerState

  import TextBasedFPS.Text

  @behaviour PlayerCommand

  @impl true
  def execute(state, player, room_name) do
    case player.name do
      nil -> {:error, state, name_required_message()}
      _ -> join_room(state, player, room_name)
    end
  end

  defp join_room(state, player, room_name) do
    with :ok <- check_already_in_room(player, room_name),
        {:ok, state} <- find_or_create_room(state, room_name) do
      state = state
      |> remove_user_from_current_room(player)
      |> notify_room(room_name, player.name)
      |> ServerState.update_room(room_name, fn room ->
        {:ok, room} = Room.add_player(room, player.key)
        room
      end)
      |> ServerState.update_player(player.key, fn player -> Map.put(player, :room, room_name) end)
      {:ok, state, success_message(room_name)}
    else
      {:error, reason} -> {:error, state, reason}
    end
  end

  defp check_already_in_room(player, room_name) when player.room == room_name do
    {:error, "You're already in this room"}
  end
  defp check_already_in_room(_player, _room_name), do: :ok

  defp remove_user_from_current_room(state, player) do
    {_, updated_state} = ServerState.remove_player_from_current_room(state, player.key)
    updated_state
  end

  defp find_or_create_room(state, room_name) do
    room = state.rooms[room_name]
    find_or_create_room(state, room_name, room)
  end
  defp find_or_create_room(state, room_name, nil), do: create_room(state, room_name)
  defp find_or_create_room(state, _room_name, _room), do: {:ok, state}

  defp create_room(state, room_name) do
    case Room.validate_name(room_name) do
      :ok -> {:ok, put_in(state.rooms[room_name], Room.new(room_name))}
      {:error, reason} -> {:error, reason}
    end
  end

  defp notify_room(state, room_name, player_name) do
    ServerState.notify_room(state, room_name, highlight("#{player_name} joined the room!"))
  end

  defp name_required_message do
    "You need to have a name before joining a room. Type #{highlight("set-name <name>")} to set your name."
  end

  defp success_message(room_name) do
    "You're now on #{room_name}! Type #{highlight("look")} to see where you are in the map."
  end
end
