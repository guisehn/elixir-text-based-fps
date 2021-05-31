defmodule TextBasedFPS.Player do
  defstruct key: nil, name: nil, room: nil

  def new do
    key = SecureRandom.uuid
    %TextBasedFPS.Player{key: key}
  end
end
