defmodule TextBasedFPS.Game.Command.JoinRoom do
  alias TextBasedFPS.{GameState, Text}
  alias TextBasedFPS.Game.{Command, Notifications, Player, Room}

  @behaviour Command

  @error_messages %{
    already_in_room: "You're already in this room",
    name_empty: "Room name cannot be empty",
    name_too_large: "Room name cannot exceed #{Room.name_max_length()} characters",
    name_invalid_chars: "Room name can only contain letters, numbers and hyphens",
    player_name_required:
      "You need to have a name before joining a room. Type #{Text.highlight("set-name <name>")} to set your name.",
    room_full: "This room is full"
  }

  @impl true
  def arg_example, do: "room name"

  @impl true
  def description, do: "Join a room"

  @impl true
  def execute(player, room_name) do
    with :ok <- require_player_name(player),
         :ok <- check_already_in_room(player, room_name),
         :ok <- GameState.leave_room(player.key),
         :ok <- join_existing_or_create_room(player, room_name) do
      update_player_room(room_name, player)
      notify_room(room_name, player)
      {:ok, success_message(room_name)}
    else
      {:error, reason} -> {:error, error_message(reason)}
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

  @spec join_existing_or_create_room(Player.t(), String.t()) :: :ok | {:error, atom}
  defp join_existing_or_create_room(player, room_name) do
    if GameState.room_exists?(room_name) do
      join_existing_room(player, room_name)
    else
      create_room(player, room_name)
    end
  end

  @spec join_existing_room(Player.t(), String.t()) :: :ok | {:error, :room_full}
  defp join_existing_room(player, room_name) do
    GameState.get_and_update_room(room_name, fn room ->
      case Room.add_player(room, player.key) do
        {:ok, updated_room} ->
          {:ok, updated_room}

        {:error, reason} ->
          {{:error, reason}, room}
      end
    end)
  end

  @spec create_room(Player.t(), String.t()) ::
          :ok
          | {:error, :name_empty}
          | {:error, :name_too_large}
          | {:error, :name_invalid_chars}
  defp create_room(player, room_name) do
    case Room.validate_name(room_name) do
      :ok ->
        GameState.add_room(name: room_name, first_player_key: player.key)
        :ok

      {:error, reason} ->
        {:error, :"name_#{reason}"}
    end
  end

  @spec notify_room(String.t(), Player.t()) :: :ok
  defp notify_room(room_name, player) do
    Notifications.notify_room(
      room_name,
      Text.highlight("#{player.name} joined the room!"),
      except: [player.key]
    )
  end

  @spec success_message(String.t()) :: String.t()
  defp success_message(room_name) do
    "You're now on #{room_name}! Type #{Text.highlight("look")} to see where you are in the map."
  end

  @spec error_message(atom) :: String.t()
  defp error_message(reason) do
    @error_messages[reason] || "Error: #{reason}"
  end

  defp update_player_room(room_name, player) do
    GameState.update_player(player.key, &Map.put(&1, :room, room_name))
  end
end
