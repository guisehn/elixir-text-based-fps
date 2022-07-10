defmodule TextBasedFPS.PlayerCommand do
  alias TextBasedFPS.Player

  @callback execute(Player.t(), String.t()) :: {:ok, String.t() | nil} | {:error, String.t()}
end
