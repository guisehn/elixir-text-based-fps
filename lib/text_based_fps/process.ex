defmodule TextBasedFPS.Process do
  alias __MODULE__
  alias TextBasedFPS.{Game, Text}

  defdelegate add_player(), to: Process.Players
  defdelegate add_player(player_key), to: Process.Players
  defdelegate get_player(player_key), to: Process.Players

  defdelegate add_room(opts), to: Process.RoomSupervisor
  defdelegate remove_room(opts), to: Process.RoomSupervisor
  defdelegate get_rooms(), to: Process.RoomSupervisor
  defdelegate count_rooms(), to: Process.RoomSupervisor
  defdelegate get_room(identifier), to: Process.Room, as: :get
  defdelegate update_room(room_name, fun), to: Process.Room, as: :update
  defdelegate get_and_update_room(room_name, fun), to: Process.Room, as: :get_and_update
  defdelegate room_exists?(room_name), to: Process.Room, as: :exists?

  @spec remove_player(Game.Player.key_t()) :: :ok
  def remove_player(player_key) do
    leave_room(player_key)
    Process.Players.remove_player(player_key)
  end

  @spec leave_room(Game.Player.key_t()) :: :ok
  def leave_room(player_key) do
    player_key |> Process.Players.get_player() |> do_leave_room()
    :ok
  end

  defp do_leave_room(%Game.Player{room: nil}), do: nil

  defp do_leave_room(player) do
    Process.Players.update_player(player.key, &%{&1 | room: nil})

    room = Process.Room.get(player.room)

    if map_size(room.players) == 1 do
      Process.RoomSupervisor.remove_room(room.name)
    else
      Process.Room.update(player.room, &Game.Room.remove_player(&1, player.key))
      Game.Notifications.notify_room(player.room, Text.highlight("#{player.name} left the room"))
    end
  end
end
