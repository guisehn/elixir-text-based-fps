defmodule TextBasedFPS.Player do
  alias TextBasedFPS.ServerState

  @type t :: %TextBasedFPS.Player{
    key: String.t,
    name: String.t | nil,
    room: String.t | nil,
    last_command_at: DateTime.t | nil
  }

  @type key_t :: String.t

  defstruct [:key, name: nil, room: nil, last_command_at: nil]

  @spec new(key_t | nil) :: t
  def new(key \\ nil) do
    key = key || generate_key()
    %TextBasedFPS.Player{key: key}
  end

  @spec generate_key() :: String.t
  def generate_key, do: SecureRandom.uuid

  @spec touch(t) :: t
  def touch(player) do
    Map.put(player, :last_command_at, DateTime.utc_now())
  end

  @spec validate_name(ServerState.t, String.t) :: :ok | {:error, String.t}
  def validate_name(state, name) do
    cond do
      name == "" -> {:error, "Name cannot be empty"}
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
