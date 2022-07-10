defmodule TextBasedFPS.Game.Command do
  alias TextBasedFPS.Game.Player

  @callback execute(Player.t(), String.t()) :: {:ok, String.t() | nil} | {:error, String.t()}
end
