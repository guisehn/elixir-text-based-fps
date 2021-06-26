defmodule TextBasedFPS.ServerState.Notifications do
  alias TextBasedFPS.{Notification, Player, ServerState}

  @spec add_notifications(ServerState.t(), list(Notification.t())) :: ServerState.t()
  def add_notifications(state, notifications) do
    Map.put(state, :notifications, state.notifications ++ notifications)
  end

  @spec get_and_clear_notifications(ServerState.t()) :: {list(Notification.t()), ServerState.t()}
  def get_and_clear_notifications(state) do
    updated_state = Map.put(state, :notifications, [])
    {state.notifications, updated_state}
  end

  @spec get_and_clear_notifications(ServerState.t(), Player.key_t()) ::
          {list(Notification.t()), ServerState.t()}
  def get_and_clear_notifications(state, player_key) do
    player_notifications = Enum.filter(state.notifications, &(&1.player_key == player_key))
    updated_state = Map.put(state, :notifications, state.notifications -- player_notifications)
    {player_notifications, updated_state}
  end
end
