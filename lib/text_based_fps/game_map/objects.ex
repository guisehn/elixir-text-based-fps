defmodule TextBasedFPS.GameMap.Objects do
  alias TextBasedFPS.GameMap.Objects

  @spec all() :: list(TextBasedFPS.GameMap.Object.t)
  def all do
    [Objects.AmmoPack, Objects.HealthPack]
  end
end
