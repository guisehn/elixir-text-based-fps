defmodule TextBasedFPS.Game do
  alias TextBasedFPS.{Notifications, Player, Process, Room, Text, CommandExecutor}
  alias TextBasedFPS.Process.Players

  defdelegate add_player(), to: Players
  defdelegate add_player(player_key), to: Players

  defdelegate get_player(player_key), to: Players

  defdelegate execute_command(player_key, command), to: CommandExecutor, as: :execute

  def remove_player(player_key) do
    leave_room(player_key)
    Players.remove_player(player_key)
  end

  @spec leave_room(Player.key_t()) :: :ok
  def leave_room(player_key) do
    player_key |> Process.Players.get_player() |> do_leave_room()
    :ok
  end

  defp do_leave_room(%Player{room: nil}), do: nil

  defp do_leave_room(player) do
    Process.Players.update_player(player.key, &Map.put(&1, :room, nil))

    room = Process.Room.get(player.room)

    if map_size(room.players) == 1 do
      Process.RoomSupervisor.remove_room(room.name)
    else
      Process.Room.update_room(player.room, &Room.remove_player(&1, player.key))
      Notifications.notify_room(player.room, Text.highlight("#{player.name} left the room"))
    end
  end
end
