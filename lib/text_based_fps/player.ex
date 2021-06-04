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

  def validate_name(state, name) do
    cond do
      String.length(name) > 20 -> {:error, "Name cannot exceed 20 characters"}
      String.match?(name, ~r/[^a-zA-Z0-9-]/) -> {:error, "Name can only contain letters, numbers and hyphens."}
      name_exists?(state, name) -> {:error, "Name is already in use"}
      true -> :ok
    end
  end

  defp name_exists?(state, name) do
    Enum.any?(state.players, fn {_, player} -> player.name == name end)
  end
end
