defmodule TextBasedFPS.ServerState do
  alias TextBasedFPS.{Player, ServerState}

  @type t :: %ServerState{
          rooms: %{String.t() => Room.t()},
          players: %{Player.key_t() => Player.t()},
          notifications: list(Notification.t())
        }

  defstruct [:rooms, :players, :notifications]

  @spec new() :: ServerState.t()
  def new do
    %ServerState{players: %{}, rooms: %{}, notifications: []}
  end

  defdelegate add_player(state), to: ServerState.Players
  defdelegate add_player(state, key), to: ServerState.Players
  defdelegate get_player(state, player_key), to: ServerState.Players
  defdelegate update_player(state, player_key, fun), to: ServerState.Players
  defdelegate remove_player(state, player_key), to: ServerState.Players

  defdelegate add_notifications(state, notifications), to: ServerState.Notifications
  defdelegate get_and_clear_notifications(state), to: ServerState.Notifications
  defdelegate get_and_clear_notifications(state, player_key), to: ServerState.Notifications

  defdelegate add_room(state, room_name), to: ServerState.Rooms
  defdelegate add_room(state, room_name, player_key), to: ServerState.Rooms
  defdelegate get_room(state, room_name), to: ServerState.Rooms
  defdelegate update_room(state, room_name, fun), to: ServerState.Rooms
  defdelegate update_room(state, room), to: ServerState.Rooms
  defdelegate join_room(state, room_name, player_key), to: ServerState.Rooms
  defdelegate join_room!(state, room_name, player_key), to: ServerState.Rooms
  defdelegate remove_player_from_current_room(state, player_key), to: ServerState.Rooms
  defdelegate notify_room(state, room_name, notification_body), to: ServerState.Rooms

  defdelegate notify_room_except_player(state, room_name, except_player_key, notification_body),
    to: ServerState.Rooms
end
