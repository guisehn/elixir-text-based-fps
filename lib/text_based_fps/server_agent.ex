defmodule TextBasedFPS.ServerAgent do
  use Agent

  alias TextBasedFPS.CommandExecutor
  alias TextBasedFPS.Notification
  alias TextBasedFPS.Player
  alias TextBasedFPS.ServerState

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

  @spec get_and_clear_notifications() :: list(Notification.t())
  def get_and_clear_notifications do
    Agent.get_and_update(__MODULE__, &ServerState.get_and_clear_notifications/1)
  end

  @spec get_and_clear_notifications(Player.key_t()) :: list(Notification.t())
  def get_and_clear_notifications(player_key) do
    Agent.get_and_update(__MODULE__, &ServerState.get_and_clear_notifications(&1, player_key))
  end

  @spec run_command(Player.key_t(), String.t()) :: {:ok, String.t() | nil} | {:error, String.t()}
  def run_command(player_key, command) do
    Agent.get_and_update(
      __MODULE__,
      fn state ->
        {status, state, message} = CommandExecutor.execute(state, player_key, command)
        {{status, message}, state}
      end
    )
  end
end
