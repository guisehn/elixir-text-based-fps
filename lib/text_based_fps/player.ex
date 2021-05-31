defmodule TextBasedFPS.Player do
  defstruct [:key, name: nil, room: nil, last_command_at: nil]

  def new, do: %TextBasedFPS.Player{key: generate_key()}

  def generate_key, do: SecureRandom.uuid

  def touch(player) do
    Map.put(player, :last_command_at, DateTime.utc_now())
  end
end
