defmodule TextBasedFPS.GameTestUtils do
  alias TextBasedFPS.{Game, Process}

  @typep notification_expectation_fun :: (Player.key_t(), String.t() -> any)

  @doc "Adds a player to a room. If any of them don't yet exist, they're created."
  def join_room(player_key, room_name) do
    unless Process.Players.get_player(player_key), do: Process.Players.add_player(player_key)
    unless Process.Room.exists?(room_name), do: Process.RoomSupervisor.add_room(name: room_name)
    Process.Room.update(room_name, &Game.Room.add_player!(&1, player_key))
    Process.Players.update_player(player_key, &%{&1 | room: room_name})
  end

  @spec expect_notification(notification_expectation_fun) :: any
  def expect_notification(expectation_fun \\ fn _, _ -> nil end) do
    expect_notifications(1, expectation_fun)
  end

  @spec expect_notifications(non_neg_integer, notification_expectation_fun) :: any
  def expect_notifications(quantity, expectation_fun \\ fn _, _ -> nil end) do
    Mox.expect(
      TextBasedFPS.Game.Notifications.Notifier.Mock,
      :notify,
      quantity,
      fn player_key, msg ->
        expectation_fun.(player_key, msg)
        :ok
      end
    )
  end
end
