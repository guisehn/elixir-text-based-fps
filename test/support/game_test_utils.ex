defmodule TextBasedFPS.GameTestUtils do
  @moduledoc "Utility functions for testing game logic"

  alias TextBasedFPS.{Game, GameState}
  alias TextBasedFPS.GameMap

  @typep notification_expectation_fun :: (Player.key_t(), String.t() -> any)

  @spec create_player(String.t(), String.t() | nil) :: :ok
  def create_player(player_key, name \\ nil) do
    unless GameState.Players.get_player(player_key) do
      GameState.Players.add_player(player_key)
      GameState.Players.update_player(player_key, &%{&1 | name: name || player_key})
    end

    :ok
  end

  @spec create_room(String.t(), String.t() | nil) :: :ok
  def create_room(room_name, room_map \\ nil) do
    unless GameState.Room.exists?(room_name),
      do: GameState.RoomSupervisor.add_room(name: room_name)

    if room_map do
      GameState.Room.update(room_name, &%{&1 | game_map: GameMap.Builder.build(room_map)})
    end

    :ok
  end

  @doc "Adds a player to a room. If the room doesn't exist, create it."
  @spec join_room(String.t(), String.t()) :: :ok
  def join_room(player_key, room_name) do
    unless GameState.Players.get_player(player_key),
      do: raise("Player #{player_key} does not exist.")

    create_room(room_name)
    GameState.Room.update(room_name, &Game.Room.add_player!(&1, player_key))
    GameState.Players.update_player(player_key, &%{&1 | room: room_name})

    :ok
  end

  @doc "Expect that a single notification is sent."
  @spec expect_notification(notification_expectation_fun) :: any
  def expect_notification(expectation_fun \\ fn _, _ -> nil end) do
    expect_notifications(1, expectation_fun)
  end

  @doc "Expect that multiple notifications are sent."
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
