defmodule TextBasedFPS.PlayerCommand do
  alias TextBasedFPS.{Player, ServerState}

  @callback execute(ServerState.t(), Player.t(), String.t()) ::
              {:ok, ServerState.t(), String.t() | nil} | {:error, ServerState.t(), String.t()}
end
