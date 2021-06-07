defmodule TextBasedFPS.GameMap.Objects do
  alias TextBasedFPS.GameMap.Objects

  @spec all() :: list(TextBasedFPS.GameMap.Object.t)
  def all do
    [Objects.AmmoPack, Objects.HealthPack]
  end

  @spec object?(any) :: boolean
  def object?(object) do
    is_map(object) && object.__struct__
    |> Module.split()
    |> List.pop_at(-1)
    |> elem(1)
    |> Module.concat
    |> Kernel.==(TextBasedFPS.GameMap.Objects)
  end
end
