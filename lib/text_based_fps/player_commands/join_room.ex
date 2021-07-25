defmodule TextBasedFPS.PlayerCommand.JoinRoom do
  import TextBasedFPS.Text, only: [highlight: 1]

  alias TextBasedFPS.{Player, PlayerCommand, Room, ServerState}

  @behaviour PlayerCommand

  @error_messages %{
    already_in_room: "You're already in this room",
    name_empty: "Room name cannot be empty",
    name_too_large: "Room name cannot exceed 20 characters",
    name_invalid_chars: "Room name can only contain letters, numbers and hyphens",
    player_name_required:
      "You need to have a name before joining a room. Type #{highlight("set-name <name>")} to set your name.",
    room_full: "This room is full"
  }

  @impl true
  def execute(state, player, room_name) do
    with :ok <- require_player_name(player),
         :ok <- check_already_in_room(player, room_name),
         {:ok, state} <- join_existing_or_create_room(state, room_name, player.key),
         state <- notify_room(state, room_name, player) do
      {:ok, state, success_message(room_name)}
    else
      {:error, reason} -> {:error, state, error_message(reason)}
    end
  end

  @spec require_player_name(Player.t()) :: :ok | {:error, :player_name_required}
  defp require_player_name(player) do
    if player.name, do: :ok, else: {:error, :player_name_required}
  end

  @spec check_already_in_room(Player.t(), String.t()) :: :ok | {:error, :already_in_room}
  defp check_already_in_room(player, room_name) do
    if player.room != room_name, do: :ok, else: {:error, :already_in_room}
  end

  @spec join_existing_or_create_room(ServerState.t(), String.t(), Player.key_t()) ::
          {:ok, ServerState.t()} | {:error, atom()}
  defp join_existing_or_create_room(state, room_name, player_key) do
    if state.rooms[room_name] do
      join_existing_room(state, room_name, player_key)
    else
      create_room(state, room_name, player_key)
    end
  end

  @spec join_existing_room(ServerState.t(), String.t(), Player.key_t()) ::
          {:ok, ServerState.t()} | {:error, :room_full}
  defp join_existing_room(state, room_name, player_key) do
    case ServerState.join_room(state, room_name, player_key) do
      {:ok, updated_state} ->
        {:ok, updated_state}

      {:error, _state, reason} ->
        {:error, reason}
    end
  end

  @spec create_room(ServerState.t(), String.t(), Player.key_t()) ::
          {:ok, ServerState.t()}
          | {:error, :name_empty}
          | {:error, :name_too_large}
          | {:error, :name_invalid_chars}
  defp create_room(state, room_name, player_key) do
    case Room.validate_name(room_name) do
      :ok -> {:ok, ServerState.add_room(state, room_name, player_key)}
      {:error, reason} -> {:error, :"name_#{reason}"}
    end
  end

  @spec notify_room(ServerState.t(), String.t(), Player.t()) :: ServerState.t()
  defp notify_room(state, room_name, player) do
    ServerState.notify_room_except_player(
      state,
      room_name,
      player.key,
      highlight("#{player.name} joined the room!")
    )
  end

  @spec success_message(String.t()) :: String.t()
  defp success_message(room_name) do
    "You're now on #{room_name}! Type #{highlight("look")} to see where you are in the map."
  end

  @spec error_message(atom) :: String.t()
  defp error_message(reason) do
    @error_messages[reason] || "Error: #{reason}"
  end
end
