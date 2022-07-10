defprotocol TextBasedFPS.GameMap.Object do
  @spec symbol(t, any) :: String.t()
  def symbol(object, room)

  @spec color(t) :: TextBasedFPS.Text.color_t()
  def color(object)

  @spec grab(t, any) :: any()
  def grab(object, room_player)
end
