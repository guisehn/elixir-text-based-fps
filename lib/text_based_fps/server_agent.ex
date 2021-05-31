defmodule TextBasedFPS.ServerAgent do
  alias TextBasedFPS.PlayerCommand
  alias TextBasedFPS.ServerState

  def start do
    Agent.start(&ServerState.new/0, name: __MODULE__)
  end

  def get_state do
    Agent.get(__MODULE__, &Function.identity/1)
  end

  def add_player do
    Agent.get_and_update(__MODULE__, &ServerState.add_player/1)
  end

  def remove_player(player_key) do
    Agent.update(__MODULE__, &(ServerState.remove_player(&1, player_key)))
  end

  def run_command(player_key, command) do
    Agent.get_and_update(
      __MODULE__,
      fn state ->
        {status, state, message} = PlayerCommand.execute(state, player_key, command)
        {{status, message}, state}
      end
    )
  end
end
