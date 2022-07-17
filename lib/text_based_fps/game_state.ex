defmodule TextBasedFPS.GameState do
  alias __MODULE__
  alias TextBasedFPS.{Game, Text}

  defdelegate add_player(), to: GameState.Players
  defdelegate add_player(player_key), to: GameState.Players
  defdelegate get_player(player_key), to: GameState.Players

  defdelegate add_room(opts), to: GameState.RoomSupervisor
  defdelegate remove_room(opts), to: GameState.RoomSupervisor
  defdelegate get_rooms(), to: GameState.RoomSupervisor
  defdelegate count_rooms(), to: GameState.RoomSupervisor
  defdelegate get_room(identifier), to: GameState.Room, as: :get
  defdelegate update_room(room_name, fun), to: GameState.Room, as: :update
  defdelegate get_and_update_room(room_name, fun), to: GameState.Room, as: :get_and_update
  defdelegate room_exists?(room_name), to: GameState.Room, as: :exists?

  @spec remove_player(Game.Player.key_t()) :: :ok
  def remove_player(player_key) do
    leave_room(player_key)
    GameState.Players.remove_player(player_key)
  end

  @spec leave_room(Game.Player.key_t()) :: :ok
  def leave_room(player_key) do
    player_key |> GameState.Players.get_player() |> do_leave_room()
    :ok
  end

  defp do_leave_room(%Game.Player{room: nil}), do: nil

  defp do_leave_room(player) do
    GameState.Players.update_player(player.key, &%{&1 | room: nil})

    room = GameState.Room.get(player.room)

    if map_size(room.players) == 1 do
      GameState.RoomSupervisor.remove_room(room.name)
    else
      GameState.Room.update(player.room, &Game.Room.remove_player(&1, player.key))
      Game.Notifications.notify_room(player.room, Text.highlight("#{player.name} left the room"))
    end
  end
end
