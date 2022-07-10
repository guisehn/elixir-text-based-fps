defmodule TextBasedFPS.Game do
  alias TextBasedFPS.{Notification, Player, Process, Room, ServerAgent}

  def join_existing_room(player, room_name) do
    remove_player_from_current_room(player)

    Process.Room.get_and_update(room_name, fn room ->
      case Room.add_player(room, player.key) do
        {:ok, updated_room} ->
          Process.Players.update_player(player.key, &Map.put(&1, :room, room_name))
          {:ok, updated_room}

        {:error, reason} ->
          {{:error, reason}, room}
      end
    end)

    :ok
  end

  def remove_player_from_current_room(%Player{room: nil}), do: :ok

  def remove_player_from_current_room(player) do
    room = Process.Room.get(player.room)

    Process.Players.update_player(player.key, &Map.put(&1, :room, nil))

    if length(room.players) == 1 do
      Process.RoomSupervisor.remove_room(room.name)
    else
      room = Process.Room.update_room(&Room.remove_player(&1, player.key))
      notify_player_leaving_room(room, player.name)
    end

    :ok
  end

  defp notify_player_leaving_room(room, leaving_player_name) do
    text = Text.highlight("#{leaving_player_name} left the room")

    notifications =
      Enum.map(room.players, fn {player_key, _} -> Notification.new(player_key, text) end)

    ServerAgent.add_notifications(notifications)
  end
end
