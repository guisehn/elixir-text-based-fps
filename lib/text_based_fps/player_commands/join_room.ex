defmodule TextBasedFPS.PlayerCommand.JoinRoom do
  alias TextBasedFPS.PlayerCommand
  alias TextBasedFPS.Room
  alias TextBasedFPS.ServerState

  import TextBasedFPS.Text, only: [highlight: 1]

  @behaviour PlayerCommand

  @impl true
  def execute(state, player, room_name) do
    case player.name do
      nil -> {:error, state, player_name_required_message()}
      _ -> join_room(state, player, room_name)
    end
  end

  defp join_room(state, player, room_name) do
    with :ok <- check_already_in_room(player, room_name),
        {:ok, state} <- join_existing_or_create_room(state, room_name, player.key),
        state <- notify_room(state, room_name, player) do
      {:ok, state, success_message(room_name)}
    else
      {:error, reason} -> {:error, state, reason}
    end
  end

  defp check_already_in_room(player, room_name) when player.room == room_name do
    {:error, "You're already in this room"}
  end
  defp check_already_in_room(_player, _room_name), do: :ok

  defp join_existing_or_create_room(state, room_name, player_key) do
    case state.rooms[room_name] do
      nil -> create_room(state, room_name, player_key)
      _ -> {:ok, ServerState.join_room(state, room_name, player_key)}
    end
  end

  defp create_room(state, room_name, player_key) do
    case Room.validate_name(room_name) do
      :ok -> {:ok, ServerState.add_room(state, room_name, player_key)}
      {:error, reason} -> {:error, name_validation_error_message(reason)}
    end
  end

  defp notify_room(state, room_name, player) do
    ServerState.notify_room_except_player(
      state,
      room_name,
      player.key,
      highlight("#{player.name} joined the room!")
    )
  end

  defp player_name_required_message do
    "You need to have a name before joining a room. Type #{highlight("set-name <name>")} to set your name."
  end

  defp success_message(room_name) do
    "You're now on #{room_name}! Type #{highlight("look")} to see where you are in the map."
  end

  defp name_validation_error_message(:empty) do
    "Room name cannot be empty"
  end
  defp name_validation_error_message(:too_large) do
    "Room name cannot exceed 20 characters"
  end
  defp name_validation_error_message(:invalid_chars) do
    "Room name can only contain letters, numbers and hyphens"
  end
end
