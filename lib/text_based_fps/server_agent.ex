defmodule TextBasedFPS.ServerAgent do
  use Agent

  alias TextBasedFPS.{CommandExecutor, Notification, Player, ServerState}

  def start_link(_) do
    Agent.start_link(&ServerState.new/0, name: __MODULE__)
  end

  @spec get_state() :: ServerState.t()
  def get_state do
    Agent.get(__MODULE__, &Function.identity/1)
  end

  @spec add_player() :: Player.key_t()
  def add_player do
    Agent.get_and_update(__MODULE__, &ServerState.add_player/1)
  end

  @spec add_player(Player.key_t()) :: :ok
  def add_player(key) do
    Agent.update(__MODULE__, &ServerState.add_player(&1, key))
  end

  @spec get_player(Player.key_t()) :: Player.t() | nil
  def get_player(key) do
    Agent.get(__MODULE__, &ServerState.get_player(&1, key))
  end

  @spec remove_player(Player.key_t()) :: :ok
  def remove_player(player_key) do
    Agent.update(__MODULE__, &ServerState.remove_player(&1, player_key))
  end

  def add_notifications(notifications) do
    Agent.update(__MODULE__, &ServerState.add_notifications(&1, notifications))
  end

  def notify_room_except_player(room_name, except_player_key, notification_body) do
    Agent.get_and_update(
      __MODULE__,
      &ServerState.notify_room_except_player(&1, room_name, except_player_key, notification_body)
    )
  end

  @spec get_and_clear_notifications() :: list(Notification.t())
  def get_and_clear_notifications do
    Agent.get_and_update(__MODULE__, &ServerState.get_and_clear_notifications/1)
  end

  @spec get_and_clear_notifications(Player.key_t()) :: list(Notification.t())
  def get_and_clear_notifications(player_key) do
    Agent.get_and_update(__MODULE__, &ServerState.get_and_clear_notifications(&1, player_key))
  end
end
