defmodule TextBasedFPS.Player do
  defstruct [:key, name: nil, room: nil, last_command_at: nil]

  def new(key \\ nil) do
    key = key || generate_key()
    %TextBasedFPS.Player{key: key}
  end

  def generate_key, do: SecureRandom.uuid

  def touch(player) do
    Map.put(player, :last_command_at, DateTime.utc_now())
  end
end
