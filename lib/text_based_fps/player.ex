defmodule TextBasedFPS.Player do
  alias TextBasedFPS.ServerState

  defstruct [:key, name: nil, room: nil, last_command_at: nil]

  @type t :: %TextBasedFPS.Player{
          key: String.t(),
          name: String.t() | nil,
          room: String.t() | nil,
          last_command_at: DateTime.t() | nil
        }

  @type key_t :: String.t() | pid()

  @name_max_length 20

  @spec new(key_t) :: t
  def new(key) do
    %TextBasedFPS.Player{key: key}
  end

  @spec generate_key() :: String.t()
  def generate_key, do: SecureRandom.uuid()

  @spec touch(t) :: t
  def touch(player) do
    Map.put(player, :last_command_at, DateTime.utc_now())
  end

  @spec validate_name(ServerState.t(), String.t()) ::
          :ok
          | {:error, :empty}
          | {:error, :too_large}
          | {:error, :invalid_chars}
          | {:error, :already_in_use}
  def validate_name(state, name) do
    cond do
      name == "" -> {:error, :empty}
      String.length(name) > @name_max_length -> {:error, :too_large}
      String.match?(name, ~r/[^a-zA-Z0-9-]/) -> {:error, :invalid_chars}
      name_exists?(state, name) -> {:error, :already_in_use}
      true -> :ok
    end
  end

  @spec name_max_length() :: non_neg_integer()
  def name_max_length, do: @name_max_length

  defp name_exists?(state, name) do
    Enum.any?(state.players, fn {_, player} -> player.name == name end)
  end
end
