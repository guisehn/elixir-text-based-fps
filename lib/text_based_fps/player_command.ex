defmodule TextBasedFPS.PlayerCommand do
  alias TextBasedFPS.ServerState
  alias TextBasedFPS.Player

  @callback execute(%ServerState{}, %Player{}, String.t()) :: {:ok, %ServerState{}, String.t() | nil} | {:error, %ServerState{}, String.t()}
end
