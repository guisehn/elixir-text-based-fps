defmodule TextBasedFPS.Game do
  alias TextBasedFPS.{Notification, Player, Process, Room, ServerAgent}
  alias TextBasedFPS.Process.Players

  # TODO:
  # Game.add_player()
  # Game.add_player(key)
  # Game.remove_player(key)
  # Game.join_room(player_key, room_name)
  # Game.leave_room(player_key)
  # Game.notify(room_name, body, except: x)
  # Game.notify(room_name, body, only: x)
  # Game.notify(room_name, body)
  # Game.flush_notifications(room_name)
  # Game.run_command(player_key, command)

  def remove_player(player_key) do
    player = Players.get_player(player_key)
    remove_player_from_current_room(player)
    Players.remove_player(player_key)
  end

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

    if map_size(room.players) |> IO.inspect("== map size ==") == 1 do
      Process.RoomSupervisor.remove_room(room.name)
    else
      room = Process.Room.update_room(player.room, &Room.remove_player(&1, player.key))
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
