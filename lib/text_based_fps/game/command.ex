defmodule TextBasedFPS.Game.Command do
  alias TextBasedFPS.Game.Player

  @callback arg_example() :: String.t()
  @callback description() :: String.t()
  @callback execute(Player.t(), String.t()) :: {:ok, String.t() | nil} | {:error, String.t()}

  @optional_callbacks arg_example: 0
end
