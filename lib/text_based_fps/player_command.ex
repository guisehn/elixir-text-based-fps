defmodule TextBasedFPS.PlayerCommand do
  alias TextBasedFPS.ServerState
  alias TextBasedFPS.Player

  @callback execute(ServerState.t, Player.t, String.t) :: {:ok, ServerState.t, String.t | nil} | {:error, ServerState.t, String.t}
end
